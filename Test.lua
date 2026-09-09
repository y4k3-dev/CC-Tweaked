local repo = "y4k3-dev/CC-Tweaked"
local branch = "main"
local folder = "CC-Tweaked"

print("Syncing with GitHub...")

-- 1. Wipe the old folder to ensure we don't have leftover deleted files
if fs.exists(folder) then
    fs.delete(folder)
end

-- 2. Clone the fresh repository (Assuming you installed the github tool earlier)
shell.run("github", "clone", repo, "-b", branch)

-- 3. Run YOUR startup file from the downloaded repository
local repo_startup = folder .. "/startup.lua"

if fs.exists(repo_startup) then
    print("Handing over control to repository...")
    shell.run(repo_startup)
else
    print("Error: Could not find startup.lua inside the repository!")
end