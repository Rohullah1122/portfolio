import { useStore } from "../../store/portfolio";
import { Reveal, Section } from "./ui";

const Experience = () => {
    const { experience } = useStore();
    if (!experience.length) return null;



    return (
        <Section id="experience" kicker="experience" title="Where I’ve worked and studied.">
            <ol className="relative ml-2 border-l border-line">
                {experience.map((x,i) => (
                    <li key={i} className="relative pb-10 pl-8 last:pb-0">
                        <span aria-hidden className={`absolute -left-[7px] top-1.5 h-3.5 w-3.5 rounded-full border-2 border-ink ${x.kind === "work" ? "bg-mint" : "bg-link"}`} />
                        <Reveal>
                            <p className="font-mono text-xs uppercase text-mute">
                                {[x.start,x.end].filter(Boolean).join(" – ")}
                                <span className={`ml-3 rounded-full px-2 py-0.5 normal-case ${x.kind === "work" ? "bg-mint/15 text-mint" : "bg-link/15 text-link"}`}>{x.kind === "work" ? "Work" : "Education"}</span>
                            </p>
                            <h3 className="mt-2 font-display text-xl font-semibold text-white">{x.title}</h3>
                            {(x.org || x.location) && <p className="text-mute">{[x.org,x.location].filter(Boolean).join(" · ")}</p>}
                            {x.desc && <p className="mt-3 max-w-2xl whitespace-pre-line leading-relaxed text-[#cdd8ea]">{x.desc}</p>}
                        </Reveal>
                    </li>
                ))}
            </ol>
        </Section>
    );
};

export default Experience;
