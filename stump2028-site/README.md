# STUMP 2028: deploying your own website

This folder is the whole site:

| File | What it is |
|---|---|
| `index.html` | The game (campaign mode, head-to-head draft, profiles, leaderboard) |
| `config.js` | Your Supabase keys go here. With placeholders, the game still works but uses local-only profiles. |
| `supabase/schema.sql` | Database tables, security rules and the leaderboard. Run once in Supabase. |

Total setup time is about 20 minutes and costs $0 on free tiers. A custom domain is optional (about $10–15 a year).

---

## Step 1: Create the backend (Supabase, free)

Supabase gives you user accounts, a database and the real-time connection that online head-to-head uses.

1. Go to **supabase.com**, sign up, then click **New project**. Pick any name and region and save the database password somewhere.
2. When the project is ready, open **SQL Editor → New query**, paste the entire contents of `supabase/schema.sql` and click **Run**. You should see "Success."
3. Open **Project Settings → API** (or the **Connect** button). Copy:
   - the **Project URL**, which looks like `https://abcdxyz.supabase.co`
   - the **anon public** key, a long string starting with `eyJ...` (or the newer "publishable" key)
4. Paste both into `config.js`. The anon key is meant to be public. The security rules in the schema stop anyone from editing other people's data.

## Step 2: Put the site online (Netlify or Vercel, free)

**Easiest: Netlify Drop**
1. Go to **app.netlify.com/drop** and drag this whole folder onto the page.
2. Create a free account to keep the site, then open **Site configuration → Change site name** (e.g. `stump2028` gives you `stump2028.netlify.app`).

**Better if you'll keep updating it: GitHub + Vercel**
1. Put this folder in a GitHub repository.
2. On **vercel.com**, choose **Add New → Project**, import the repository and click **Deploy**. There's no build step.
3. From then on, every change you push to GitHub updates the site automatically.

## Step 3: Connect sign-in to your site's address

In Supabase, open **Authentication → URL Configuration**:
- **Site URL**: your site address, e.g. `https://stump2028.netlify.app`
- **Redirect URLs**: add that same address with `/**` at the end (e.g. `https://stump2028.netlify.app/**`)

Then open your site, click **👤 Sign in**, enter your email, open the link you receive, and pick a username. You'll appear on the 🏆 Leaderboard after your first finished game.

## Optional upgrades

- **Custom domain**: buy one (Cloudflare, Namecheap or Porkbun), add it in Netlify or Vercel under **Domains**, then update the Supabase Site URL and Redirect URLs to the new domain.
- **"Continue with Google" button**: enable Google in Supabase **Authentication → Providers** (follow its guide to create Google OAuth keys), then set `googleAuth: true` in `config.js`.
- **Sign-in emails at scale**: Supabase's built-in email sender only allows a few emails per hour. That's fine for testing and friends. Before a public launch, add a custom SMTP provider (Resend, Postmark or similar) under **Authentication → Emails → SMTP Settings**.

## How the pieces work

- **Profiles and records**: each finished game is saved to the `games` table and achievements to `achievements`. The `leaderboard` view totals them.
- **Online head-to-head**: players meet in a room through Supabase Realtime "broadcast" channels, using a 5-letter room code. No extra server is needed. The host's browser referees the auction and the turns.
- **Guests**: without signing in, records and achievements are kept in that browser only. When a guest creates an account, their local history is uploaded once.

## Known limits (worth knowing before you go big)

- **Scores are reported by the player's browser.** Someone technical could fake a result. That's fine for a fun leaderboard among friends. If it ever needs to be tamper-proof, game results would have to be checked on a server (e.g. a Supabase Edge Function).
- **Online games can't be resumed.** If someone refreshes or loses connection mid-game, that match ends.
- **Free-tier limits**: Supabase free allows about 200 people connected to realtime at once and 50,000 monthly active users. Projects pause after a week with no activity (one click to restore).

## Updating the game

Replace `index.html` with a new version and re-deploy (drag the folder again, or push to GitHub). Leave `config.js` alone so your keys stay put.
