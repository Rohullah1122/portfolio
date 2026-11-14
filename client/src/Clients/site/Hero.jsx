import { useStore } from "../../store/portfolio";

export default function Hero() {
  const { profile, projects, skills } = useStore();
  const words = profile.name.trim().split(" ");
  const last = words.pop();
  const tech = new Set(skills.flatMap((g) => g.items)).size;
  const stats = [[projects.length, "Projects"], [projects.filter((p) => p.status === "Completed").length, "Completed"], [tech, "Technologies"]];
  const btn = "rounded-lg px-6 py-3 text-sm font-semibold no-underline transition";

  return (
    <section id="home" className="relative overflow-hidden pt-28 pb-14 md:pt-36 md:pb-20">
      <div aria-hidden className="bp-grid absolute inset-0 opacity-30" />
      <div className="relative mx-auto grid max-w-6xl items-center gap-10 px-6 md:grid-cols-[1.3fr_1fr]">
        <div>
          {profile.available && (
            <p className="inline-flex items-center gap-2 rounded-full border border-line bg-panel px-3 py-1 text-sm text-mute">
              <span className="h-2 w-2 rounded-full bg-mint motion-safe:animate-pulse" />Available for work
            </p>
          )}
          <p className="mt-6 font-mono text-sm text-mint">{`// ${profile.role.toLowerCase()}`}</p>
          <h1 className="mt-3 font-display text-4xl font-bold tracking-tight text-white md:text-6xl">
            {words.join(" ")} <span className="text-mint">{last}</span>
          </h1>
          <p className="mt-4 max-w-xl text-lg leading-relaxed text-mute">{profile.bio}</p>
          <div className="mt-7 flex flex-wrap gap-3">
            <a href="#projects" className={`${btn} bg-mint text-ink hover:brightness-110`}>View projects</a>
            <a href="#contact" className={`${btn} border border-line text-white hover:border-mint/60`}>Contact me</a>
            {profile.resume && <a href={profile.resume} target="_blank" rel="noreferrer" download className={`${btn} border border-line text-white hover:border-mint/60`}>Download resume ↓</a>}
            {profile.github && <a href={profile.github} target="_blank" rel="noreferrer" className={`${btn} text-mute hover:text-white`}>GitHub ↗</a>}
            {profile.linkedin && <a href={profile.linkedin} target="_blank" rel="noreferrer" className={`${btn} text-mute hover:text-white`}>LinkedIn ↗</a>}
          </div>
          <dl className="mt-9 flex gap-10">
            {stats.map(([n, l]) => (
              <div key={l}><dd className="font-display text-2xl font-bold text-white">{n}</dd><dt className="text-sm text-mute">{l}</dt></div>
            ))}
          </dl>
        </div>
        <div className="relative mx-auto w-full max-w-[17rem]">
          {profile.avatar && <img src={profile.avatar} alt={profile.name} className="relative aspect-square w-full rounded-full bg-raise object-cover ring-1 ring-line ring-offset-8 ring-offset-ink" />}
        </div>
      </div>
    </section>
  );
}
