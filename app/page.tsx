export default function Home() {
  return (
    <main className="min-h-screen bg-black text-white">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 bg-black/80 backdrop-blur-md border-b border-white/5">
        <div className="max-w-6xl mx-auto px-6 h-14 flex items-center justify-between">
          <div className="text-xl font-semibold tracking-tight">Agency</div>
          <div className="flex items-center gap-8 text-sm text-white/70">
            <a href="#creators" className="hover:text-white transition">Creators</a>
            <a href="#tools" className="hover:text-white transition">Tools</a>
            <a href="#skills" className="hover:text-white transition">Skills</a>
            <button className="bg-white text-black px-4 py-1.5 rounded-full text-sm font-medium hover:bg-white/90 transition">
              Launch
            </button>
          </div>
        </div>
      </nav>

      {/* Hero */}
      <section className="pt-40 pb-32 px-6">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-5xl md:text-7xl font-semibold tracking-tight leading-[1.1] mb-6">
            Ownership.<br />
            Skills.<br />
            Tools.
          </h1>
          <p className="text-xl md:text-2xl text-white/60 max-w-2xl mx-auto mb-12 leading-relaxed">
            The permissionless launchpad for creators, builders, and educators.
            Launch tokens that give people real agency.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button className="bg-white text-black px-8 py-3.5 rounded-full text-lg font-medium hover:bg-white/90 transition">
              Get started
            </button>
            <button className="border border-white/20 text-white px-8 py-3.5 rounded-full text-lg font-medium hover:bg-white/5 transition">
              Learn more
            </button>
          </div>
        </div>
      </section>

      {/* Three pillars */}
      <section className="py-24 px-6 border-t border-white/5">
        <div className="max-w-6xl mx-auto grid md:grid-cols-3 gap-12">
          <div id="creators" className="space-y-4">
            <div className="text-sm font-medium text-white/40 tracking-widest uppercase">01</div>
            <h2 className="text-2xl font-semibold">Creator Equity</h2>
            <p className="text-white/60 leading-relaxed">
              Creators launch tokens tied to their work. Fans get real ownership and share in the upside.
            </p>
          </div>
          <div id="tools" className="space-y-4">
            <div className="text-sm font-medium text-white/40 tracking-widest uppercase">02</div>
            <h2 className="text-2xl font-semibold">Open Tools</h2>
            <p className="text-white/60 leading-relaxed">
              Builders fund open-source tools and public goods. Community-owned infrastructure that lasts.
            </p>
          </div>
          <div id="skills" className="space-y-4">
            <div className="text-sm font-medium text-white/40 tracking-widest uppercase">03</div>
            <h2 className="text-2xl font-semibold">Skill Forge</h2>
            <p className="text-white/60 leading-relaxed">
              Educators launch tokens for skills and learning paths. Unlock knowledge through ownership.
            </p>
          </div>
        </div>
      </section>

      {/* Tagline section */}
      <section className="py-32 px-6 border-t border-white/5">
        <div className="max-w-3xl mx-auto text-center">
          <p className="text-3xl md:text-4xl font-medium tracking-tight leading-snug text-white/90">
            Built for people,<br />not just memes.
          </p>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-12 px-6 border-t border-white/5">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row justify-between items-center gap-4 text-sm text-white/40">
          <div>© 2026 Agency</div>
          <div className="flex gap-6">
            <a href="https://github.com/wizard9502/agency" className="hover:text-white transition">GitHub</a>
            <span>Arc · BNB · More coming</span>
          </div>
        </div>
      </footer>
    </main>
  );
}
