// STUMP 2028 site configuration.
// Fill these in from Supabase → Project Settings → API (or "Connect").
// The anon/publishable key is designed to be public; Row Level Security protects the data.
// Leave the placeholders as-is to run the game without accounts (local profiles only).
window.STUMP_CONFIG = {
  supabaseUrl: "YOUR_SUPABASE_URL",          // e.g. "https://abcdxyz.supabase.co"
  supabaseAnonKey: "YOUR_SUPABASE_ANON_KEY", // the long "anon public" key
  googleAuth: false                          // set true after enabling Google in Supabase → Auth → Providers
};
