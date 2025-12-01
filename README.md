## Learning Bash :)
## SogeLogs Version 0.1.4
### Setup 
Must add "sogelogs" alias to bash profile.
*  On Apple Silicon: ~/.zshrc
```
alias sogelogs="/Path/to/script.sh"
```
Example: 
```
alias sogelogs="~/Scripts/sogelogs/sogelogs.sh"
``` 
---
### User Functionality 
 
``` > sogelogs ``` 
Opens Menu

#### Options
| Flag | | |
|----|----|----|
| -h | Displays help message. | |
| -a | Prints all logs. | |
| | --help | Prints commands to help navigate all logs. |
| | --thought | Prints all thoughts. |
| | --proverb | Prints all sogeverbs. |
| -n | Create a new entry. | |
| | --workout | Prompts new workout entry. |
| | --thought | Prompts open text for a new thought. |
| | --proverb | Prompts open text for a new sogeverb. |
| | --expressive | Launches the expressive writing prompt. |
| | --gratitude | Launches the gratitude journaling prompt. |
| | --reflective | Launches the reflective reframing prompt. |
| | --done | Prompts new done list entry. |
| -r | | |
| | --thought | Gets a random thought. |
| | --proverb | Gets a random sogeverb. |
| | --expressive | Gets a random expressive writing entry. |
| | --gratitude | Gets a random gratitude journaling entry. |
| | --reflective | Gets a random reflective reframing entry. |
| -s | Statistics. | |
| | --workout | Gets all workout statistics. |
| | --workout {exercise} | Gets statistics for {exercise}. |
| | --done | Gets statistics for completed tasks. |

### Writing Prompts
Writing prompts work like standard journal entries, but the selected prompt is displayed in color before the capture window opens. Each response is tagged so it can be surfaced later with `-r`.

- **Expressive Writing** – When emotions feel heavy or a moment keeps looping. Writing completes the loop so your brain can move on.
- **Gratitude Journaling** – When you feel numb or distant. Focus on specific positive details to retrain your attention.
- **Reflective Reframing** – When life feels confusing. Walk through what happened, what it meant, what it revealed, what it taught you, and finish with a small action for next time.

Use `sogelogs -n --expressive`, `--gratitude`, or `--reflective` to log directly from the terminal, or pick the “Writing Prompts” option (9) inside the interactive menu. When you need inspiration later, run `sogelogs -r --expressive` (or the other prompt flags) for a random past entry.
