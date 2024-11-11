### SogeLogs Version 0.1 
---
#### Setup 
Must add "sogelogs" alias to bash profile.
```
alias sogelogs="/Path/to/script.sh"
```
Example: 
```
alias sogelogs="~/Scripts/sogelogs/sogelogs.sh"
``` 
*  On Apple Silicon 
  * ~/.zshrc
#### User Functionality 
 
``` > sogelogs ``` 
Opens Menu

#### Options
| Flag | |
|----|-------------------|
| -h | Displays help message. |
| -n | Create a new entry. |
| --workout | Prompts new workout entry. |
| --thought | Prompts open text for a new thought. |
| -r | Gets a Random Thought. |
| -s | Statistics. | 
| --workout | Gets all workout statistics. |
| --workout <exercise> | Gets statistics for <exercise>. |