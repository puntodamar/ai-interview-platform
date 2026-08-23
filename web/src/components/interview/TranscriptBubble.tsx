import {cn} from "@/lib/utils";

interface TranscriptBubbleProps {
    speaker: "candidate" | "assessor" | "system" | "ai";
    text: string;
    createdAt?: string;
    audioStartMs?: number;
}

export default function TranscriptBubble({
                                             speaker,
                                             text,
                                             createdAt,
                                             audioStartMs,
                                         }: TranscriptBubbleProps) {
    const isCandidate = speaker === "candidate";

    let timestamp = null;
    let formattedTime = null;

    if(createdAt && audioStartMs) {
        timestamp = new Date(new Date(createdAt).getTime() + audioStartMs);
        formattedTime = timestamp.toLocaleTimeString([], {
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit",
        });


    }

    return (
        <div className={cn("flex", isCandidate ? "justify-end" : "justify-start")}>
            <div
                className={cn(
                    "max-w-[85%] rounded-lg px-3 py-2 text-sm ",
                    isCandidate
                        ? "bg-primary text-primary-foreground rounded-tr-sm"
                        : "bg-muted rounded-tl-sm"
                )}
            >
                <div className="flex items-center gap-2 mb-0.5">
                    <span className={`text-md font-medium italic ${isCandidate ? "text-primary-foreground/70" : "text-muted-foreground"}`}>
                        {isCandidate ? "Candidate" : "AI Interviewer"}
                    </span>
                </div>



                <div className="flex flex-col gap-y-1 mt-2">
                    <div>{text}</div>
                    {formattedTime && (
                        <span
                            className={`text-[10px] ${
                                isCandidate
                                    ? "text-primary-foreground/70 self-end"
                                    : "text-muted-foreground"
                            }`}
                        >
                            {formattedTime}
                        </span>
                    )}
                </div>
            </div>


        </div>
    );
}