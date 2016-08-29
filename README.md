# PSLog
A set of functions to provide structured text file logging for powershell scripts.

I ceeated this script because wanted to track the activity of powershell scripts running on servers at work.
The API is heavily inspired by the C# logging framework Serilog and the output of the text is in JSON which may not be to everyone's taste.
It is not optimised for performance and rolls over on size (currently 50Mb)

To use in a script, one needs to set $PSLogFilePath to a path on disk and optionally set the $PSLogName to a name that describes the log purpose.
Then call `. .\PATH\TO\PSLog.ps1` and either use Log-Info, Log-Warning or Log-Error with a message and optionally other properties in a hash map.

e.g.
`Log-Info "Processed thing" @{Duration=100; Size=20; ThingName="Some Thing"}`

