# scripting_system

## scripting_system is a system for simplified script usage, written in Bash.

### Using ss:

* You don’t have to remember the name, location, or options of any script that you write.
* You don’t need to change any of the code in your scripts to make them compatible with ss.
* You have a command line interface for viewing and using all of your scripts.
* You can back up all of your scripts to github because ss is freely distributable and modifiable.
* You can incorporate any script/utility/executable which can be executed from the command line normally, including perl and python scripts.
* You can group your scripts into categories entirely of your choosing.
* You can specify which options you wish to be prompted for, and customize those prompts.
* You can specify defaults for given options.
* You can specify dependencies for your script, files which must be present for it to execute.
* You can preset messages such as examples for the most common usages of your script.
* You can apply this to existing utilities which are complex, such as tar.
* You can invoke ss from the command line itself, as well as interactively.
* You can set safety warnings and mollyguards for dangerous scripts.
* You can use common functionality from ss in your own shell scripts, which takes the form of well made functions. Even if you want to move away from ss later, you can just copy the code from ss and paste it in your own script in place of the function call.
* You can automatically organize your scripts into directories by the categories you specified.
* The default repository has a bunch of helpful scripts which serve as examples for using ss.

### Other points:
* You _will_ need to write simple wrapper files for your scripts.
* There are NO dependencies other than Bash >= 4.2 . It's all done using builtins.
* Obviously, you will need an editor to edit your files, though.
* ss is not for testing or debugging.
* ss is not for scheduling of scripts.
* do not apply to forehead.

### Installation instructions:
It is strongly advised you not change any of the paths in these instructions until _after_ you have a working installation.
1. Go to your home directory.
2. git clone https://github.com/pfdint/scripting_system.git
3. mv scripting_system ss.d
4. cd ss.d
5. ./scripting_system.sh
6. Select option 1, Adapters
7. Select option 2, new_user
8. Select m to edit the wrapper file.
9. Replace 'pfdint' in the location with your own username.
10. Close the editor.
11. Select r or b to run the script.
If any dependencies are 'missing', try editing the wrapper file and commenting or deleting out those lines if you actually do have those dependencies. There's no way to know where these things will be kept on your machine!
