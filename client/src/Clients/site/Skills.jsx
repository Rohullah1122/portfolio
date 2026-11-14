import { useStore } from "../../store/portfolio";
import { Chip, Reveal, Section } from "./ui";

export default function Skills() {
  const { skills } = useStore();
  return (
    <Section id="skills" kicker="skills" title="The stack I work with.">
      <div className="grid gap-4 md:grid-cols-2">
        {skills.map((g, i) => (
          <Reveal key={g.title + i}>
            <div className="h-full rounded-xl border border-line bg-panel p-5">
              <h3 className="font-display text-lg font-semibold text-white">{g.title}</h3>
              <p className="mt-1 text-sm text-mute">{g.desc}</p>
              <div className="mt-4 flex flex-wrap gap-2">{g.items.filter(Boolean).map((n) => <Chip key={n} name={n} />)}</div>
            </div>
          </Reveal>
        ))}
      </div>
    </Section>
  );
}
