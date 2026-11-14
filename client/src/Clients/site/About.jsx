import { useStore } from "../../store/portfolio";
import { Reveal, Section } from "./ui";

export default function About() {
  const { profile } = useStore();
  return (
    <Section id="about" kicker="about" title="Building things that last.">
      <div className="grid gap-4 md:grid-cols-3">
        {profile.about.filter(Boolean).map((line, i) => (
          <Reveal key={i}>
            <div className="h-full rounded-xl border border-line bg-panel p-5">
              <p className="font-mono text-sm text-mint">{String(i + 1).padStart(2, "0")}</p>
              <p className="mt-3 text-base leading-snug text-white">{line}</p>
            </div>
          </Reveal>
        ))}
      </div>
    </Section>
  );
}
