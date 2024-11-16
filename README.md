## SogeLogs Version 0.1.1 
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
| -n | Create a new entry. | |
| | --workout | Prompts new workout entry. |
| | --thought | Prompts open text for a new thought. |
| -r | | |
| | --thought | Gets a random thought. |
| | --proverb | Gets a random sogeverb. |
| -s | Statistics. | |
| | --workout | Gets all workout statistics. |
| | --workout {exercise} | Gets statistics for {exercise}. |
