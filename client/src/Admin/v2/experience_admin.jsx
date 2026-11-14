import { useState } from "react";
import { actions, getSaveError, useStore } from "../../store/portfolio";
import { Area, Btn, Card, Input, Select } from "./fields";

const blankjob = () => ({ kind:"work",title:"",org:"",location:"",start:"",end:"",desc:"" });

const ExperienceAdmin = () => {
    const { experience } = useStore();
    const [ALE,setALE] = useState(() => experience.map((x) => ({ ...x })));
    const [msg,setmsg] = useState("");



    const change = (i,k,v) => {
        setALE(ALE.map((x,n) => (n === i ? { ...x,[k]:v } : x)));
        setmsg("");
    };

    const move = (i,k) => {
        const j = i + k;
        if (j < 0 || j >= ALE.length) return;
        const next = [...ALE];
        [next[i],next[j]] = [next[j],next[i]];
        setALE(next);
        setmsg("");
    };

    const remove = (i) => {
        setALE(ALE.filter((_,n) => n !== i));
        setmsg("");
    };

    const save = async () => {
        if (ALE.some((x) => !x.title.trim())) return setmsg("Every entry needs a title.");
        setmsg((await actions.saveExperience(ALE)) ? "Saved. Your site is updated." : getSaveError());
    };



    return (
        <div className="max-w-3xl pb-28">
            <h1 className="font-display text-3xl font-bold text-white">Experience</h1>
            <p className="mt-1 text-mute">Jobs and education, shown as a timeline on your site in this order. Put the newest first.</p>

            <div className="mt-8 space-y-6">
                {ALE.map((x,i) => (
                    <Card key={i} title={x.title || "New entry"}>
                        <div className="grid gap-4 md:grid-cols-2">
                            <Select label="Type" options={["work","education"]} value={x.kind} onChange={(e) => change(i,"kind",e.target.value)} />
                            <Input label={x.kind === "work" ? "Job title" : "Program or degree"} value={x.title} onChange={(e) => change(i,"title",e.target.value)} />
                            <Input label={x.kind === "work" ? "Company" : "School"} value={x.org} onChange={(e) => change(i,"org",e.target.value)} />
                            <Input label="Location" value={x.location} onChange={(e) => change(i,"location",e.target.value)} />
                            <Input label="Start (e.g. Sep 2023)" value={x.start} onChange={(e) => change(i,"start",e.target.value)} />
                            <Input label="End (e.g. Present)" value={x.end} onChange={(e) => change(i,"end",e.target.value)} />
                        </div>
                        <Area label="What you did" rows={3} value={x.desc} onChange={(e) => change(i,"desc",e.target.value)} />
                        <div className="flex gap-2">
                            <Btn onClick={() => move(i,-1)} disabled={i === 0}>Move up</Btn>
                            <Btn onClick={() => move(i,1)} disabled={i === ALE.length - 1}>Move down</Btn>
                            <Btn onClick={() => remove(i)}>Delete</Btn>
                        </div>
                    </Card>
                ))}

                {!ALE.length && <p className="rounded-xl border border-line bg-panel p-8 text-center text-mute">Nothing yet. The section stays hidden on your site until you add an entry.</p>}
                <Btn onClick={() => setALE([...ALE,blankjob()])}>+ Add entry</Btn>
            </div>

            <div className="fixed inset-x-0 bottom-0 z-30 border-t border-line bg-panel/95 backdrop-blur md:left-60">
                <div className="mx-auto flex max-w-3xl items-center gap-3 px-5 py-3">
                    <p role="status" className="flex-1 text-sm text-mint">{msg}</p>
                    <Btn kind="primary" onClick={save}>Save experience</Btn>
                </div>
            </div>
        </div>
    );
};

export default ExperienceAdmin;
