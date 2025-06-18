console.log("Generating TypeDoc..."); import("child_process").then(cp => cp.spawnSync("npx", ["typedoc"], { stdio: "inherit" }))
