/* Supabase client for the static graduation invitation site.
   Only the public anon key belongs here. Never add a service_role key. */
(function () {
  const SUPABASE_URL = "https://szzrslserajyukworzcd.supabase.co";
  const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6enJzbHNlcmFqeXVrd29yemNkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1NjExNTQsImV4cCI6MjA5ODEzNzE1NH0.oclG0kL37vlB45oJG7x4jO8qRdbi6zkKwW2YD769yAA";

  const hasValidConfig =
    typeof window.supabase !== "undefined" &&
    SUPABASE_URL &&
    SUPABASE_ANON_KEY &&
    !SUPABASE_ANON_KEY.includes("PASTE_");

  window.GRADUATION_SUPABASE = {
    url: SUPABASE_URL,
    isConfigured: hasValidConfig,
    client: hasValidConfig
      ? window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
      : null
  };
})();
