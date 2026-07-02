// Process invitation images for the static graduation invitation.
// This function is server-side only: no service_role/private secret is exposed to frontend code.

import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";
import {
  ImageMagick,
  initializeImageMagick,
  MagickFormat,
} from "npm:@imagemagick/magick-wasm@0.0.30";

const BUCKET_NAME = "invitation-media";
const MAX_UPLOAD_BYTES = 8 * 1024 * 1024;
const WEBP_QUALITY = 84;

const mediaSlots = {
  hero_image: {
    fileName: "hero.webp",
    label: "Ảnh chính",
    maxWidth: 1200,
    maxHeight: 1200,
  },
  guestbook_image: {
    fileName: "guestbook.webp",
    label: "Ảnh sổ lưu bút",
    maxWidth: 1000,
    maxHeight: 1000,
  },
  thank_image: {
    fileName: "thank.webp",
    label: "Ảnh thank you",
    maxWidth: 1200,
    maxHeight: 900,
  },
  admin_hero_image: {
    fileName: "admin-hero.webp",
    label: "Ảnh trang admin",
    maxWidth: 1400,
    maxHeight: 900,
  },
} as const;

type MediaSlot = keyof typeof mediaSlots;

let magickReady: Promise<void> | null = null;

function json(data: Record<string, unknown>, status = 200) {
  return Response.json(data, {
    status,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
    },
  });
}

function isMediaSlot(value: FormDataEntryValue | null): value is MediaSlot {
  return typeof value === "string" && value in mediaSlots;
}

function isSupportedImage(file: File) {
  return ["image/jpeg", "image/png", "image/webp"].includes(file.type);
}

async function ensureMagickReady() {
  if (!magickReady) {
    magickReady = (async () => {
      const wasmBytes = await Deno.readFile(
        new URL(
          "magick.wasm",
          import.meta.resolve("npm:@imagemagick/magick-wasm@0.0.30"),
        ),
      );
      await initializeImageMagick(wasmBytes);
    })();
  }
  await magickReady;
}

function resizeWithinBounds(width: number, height: number, maxWidth: number, maxHeight: number) {
  if (width <= maxWidth && height <= maxHeight) return { width, height };
  const ratio = Math.min(maxWidth / width, maxHeight / height);
  return {
    width: Math.max(1, Math.round(width * ratio)),
    height: Math.max(1, Math.round(height * ratio)),
  };
}

async function toOptimizedWebp(file: File, slot: MediaSlot) {
  await ensureMagickReady();

  const inputBytes = new Uint8Array(await file.arrayBuffer());
  const bounds = mediaSlots[slot];

  return ImageMagick.read(inputBytes, (image) => {
    if (typeof image.autoOrient === "function") image.autoOrient();

    const nextSize = resizeWithinBounds(
      image.width,
      image.height,
      bounds.maxWidth,
      bounds.maxHeight,
    );

    if (nextSize.width !== image.width || nextSize.height !== image.height) {
      image.resize(nextSize.width, nextSize.height);
    }

    image.quality = WEBP_QUALITY;

    return image.write(MagickFormat.WebP, (data) => data);
  }) as Uint8Array;
}

export default {
  fetch: withSupabase({ auth: ["user"] }, async (req, ctx) => {
    if (req.method === "OPTIONS") return json({ ok: true });

    if (req.method !== "POST") {
      return json({ error: "Method not allowed." }, 405);
    }

    const { data: permission, error: permissionError } = await ctx.supabase
      .from("admin_users")
      .select("role,email")
      .limit(1)
      .maybeSingle();

    if (permissionError) {
      return json({ error: `Không kiểm tra được quyền upload: ${permissionError.message}` }, 403);
    }

    if (!permission || !["owner", "admin"].includes(permission.role)) {
      return json({ error: "Tài khoản này chưa có quyền cập nhật ảnh." }, 403);
    }

    let form: FormData;
    try {
      form = await req.formData();
    } catch {
      return json({ error: "Request phải là multipart/form-data." }, 400);
    }

    const slot = form.get("slot");
    const file = form.get("file");

    if (!isMediaSlot(slot)) {
      return json({ error: "Vị trí ảnh không hợp lệ." }, 400);
    }

    if (!(file instanceof File)) {
      return json({ error: "Chưa nhận được file ảnh." }, 400);
    }

    if (!isSupportedImage(file)) {
      return json({ error: "Chỉ hỗ trợ JPG, PNG hoặc WebP." }, 400);
    }

    if (file.size > MAX_UPLOAD_BYTES) {
      return json({ error: "Ảnh vượt quá giới hạn 8 MB." }, 400);
    }

    let optimized: Uint8Array;
    try {
      optimized = await toOptimizedWebp(file, slot);
    } catch (error) {
      return json({
        error: `Chưa xử lý được ảnh: ${error instanceof Error ? error.message : "unknown error"}`,
      }, 422);
    }

    const storagePath = `${slot}/${mediaSlots[slot].fileName}`;
    const imageBlob = new Blob([optimized], { type: "image/webp" });

    const { error: uploadError } = await ctx.supabaseAdmin.storage
      .from(BUCKET_NAME)
      .upload(storagePath, imageBlob, {
        cacheControl: "31536000",
        contentType: "image/webp",
        upsert: true,
      });

    if (uploadError) {
      return json({ error: `Chưa upload được ảnh: ${uploadError.message}` }, 500);
    }

    const { data: publicData } = ctx.supabaseAdmin.storage
      .from(BUCKET_NAME)
      .getPublicUrl(storagePath);

    const publicUrl = `${publicData.publicUrl}?v=${Date.now()}`;

    const { data: mediaRow, error: mediaReadError } = await ctx.supabase
      .from("site_settings")
      .select("value")
      .eq("key", "invitation_media")
      .maybeSingle();

    if (mediaReadError) {
      return json({ error: `Chưa đọc được cấu hình ảnh: ${mediaReadError.message}` }, 500);
    }

    if (!mediaRow) {
      return json({ error: "Thiếu row site_settings.invitation_media." }, 500);
    }

    const nextValue = {
      ...(mediaRow.value || {}),
      [slot]: publicUrl,
      [`${slot}_path`]: storagePath,
      [`${slot}_updated_at`]: new Date().toISOString(),
    };

    const { error: updateError } = await ctx.supabase
      .from("site_settings")
      .update({ value: nextValue })
      .eq("key", "invitation_media");

    if (updateError) {
      return json({ error: `Ảnh đã upload nhưng chưa lưu được cấu hình: ${updateError.message}` }, 500);
    }

    return json({
      ok: true,
      slot,
      label: mediaSlots[slot].label,
      path: storagePath,
      publicUrl,
      bytes: optimized.byteLength,
    });
  }),
};
