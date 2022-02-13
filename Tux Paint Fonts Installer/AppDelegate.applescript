--
--  AppDelegate.applescript
--  TuxPaint Fonts Installer
--
--  Copyright (c) 2004-2022
--  Contributions by various authors
--  https://www.tuxpaint.org/
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
--  (See COPYING.txt)
--

script AppDelegate
    property parent : class "NSObject"
    property theSelectedRadioButtonId : "USER"

    -- IBOutlets
    property theWindow : missing value
    property theUserRadioButton : missing value
    property theSystemRadioButton : missing value
    property theApplicationRadioButton : missing value
    property theInstallButton : missing value
    property theRemoveButton : missing value
    property theQuitButton : missing value

    -- Application startup
    on applicationWillFinishLaunching_(aNotification)
        -- Change the title to be language-specific
        set appBundle to current application's NSBundle's mainBundle()
        set title of theWindow to appBundle's objectForInfoDictionaryKey:("CFBundleName")

        -- Refresh the window body
        refresh()
    end applicationWillFinishLaunching_

    -- Application cleanup
    on applicationShouldTerminate_(sender)
        return current application's NSTerminateNow
    end applicationShouldTerminate_

    on applicationShouldTerminateAfterLastWindowClosed_(sender)
        return true
    end applicationShouldTerminateAfterLastWindowClosed_

    -- Refresh the dialog box
    on refresh()
        set isUserFontsInstalled to isFontsInstalledAt(fontsPathOf("USER"))
        set isSystemFontsInstalled to isFontsInstalledAt(fontsPathOf("SYSTEM"))

        -- Display the user fonts installation status
        if isUserFontsInstalled then
            set title of theUserRadioButton to "Current User (already installed)"
        else
            set title of theUserRadioButton to "Current User"
        end if

        -- Display the system fonts installation status
        if isSystemFontsInstalled then
            set title of theSystemRadioButton to "All Users (already installed)"
        else
            set title of theSystemRadioButton to "All Users"
        end if

        -- Refresh the buttons
        refreshButtons()
    end refresh

    -- Enable and disable appropriate buttons
    on refreshButtons()
        -- Enable both buttons by default
        set enabled of theInstallButton to true
        set enabled of theRemoveButton to true

        -- We're done if the application is selected
        if theSelectedRadioButtonId is "APPLICATION" then
            return
        end if

        -- Check if the fonts are installed at the selected target
        set isInstalled to isFontsInstalledAt(fontsPathOf(theSelectedRadioButtonId))

        -- Disable the remove button if the selected target has no fonts to remove
        if not isInstalled then
            set enabled of theRemoveButton to false
        end if
    end refreshButtons

    -- Disable all buttons
    on disableButtons()
        set enabled of theInstallButton to false
        set enabled of theRemoveButton to false
    end disableButtons

    -- Return the name of the main fonts file to install/remove
    on getMainFontsFile()
        set archiveListPath to POSIX path of (path to resource "tuxpaint-fonts.list")
        set mainFile to missing value

        # Get the list of installable font sets
        repeat with l in paragraphs of (read archiveListPath)
            if length of l is greater than 0 then
                copy l as text to mainFile
                exit repeat
            end if
        end repeat

        return mainFile
    end getMainFontsFile

    -- Return true if our fonts are installed at thePath
    on isFontsInstalledAt(thePath)
        set mainFontsFile to getMainFontsFile()
        set isInstalled to false

        -- See if the mainFontsFile exists under thePath
        tell application "System Events"
            if exists file (thePath & "/" & mainFontsFile) then
                set isInstalled to true
            end if
        end tell

        return isInstalled
    end isFontsInstalledAt

    -- Handle radio button selection event
    on selected_(theRadioButton)
        set theSelectedRadioButtonId to theRadioButton's identifier() as text

        refreshButtons()
    end selected_

    -- Handle button click event
    on clicked_(theButton)
        set theButtonId to theButton's identifier() as text

        if theButtonId is "INSTALL" then
            install(fontsPathOf(theSelectedRadioButtonId))
        else if theButtonId is "REMOVE" then
            uninstall(fontsPathOf(theSelectedRadioButtonId))
        else if theButtonId is "QUIT" then
            quit
        else
            ackDialog("We shouldn't get here: theButtonId=" & theButtonId)
        end if
    end clicked_

    -- Given an abstract target name, return the path to its resources folder
    on fontsPathOf(theTargetId)
        set thePath to missing value

        if theTargetId is "SYSTEM" then
            set thePath to "/Library/Application Support/TuxPaint/fonts"
        else if theTargetId is "USER" then
            set HOME to system attribute "HOME"
            set thePath to HOME & "/Library/Application Support/TuxPaint/fonts"
        else if theTargetId is "APPLICATION" then
            repeat while true
                -- Bring up the file chooser
                set thePath to choose file with prompt "Please select the Tux Paint application:" of type "app"
                set thePath to POSIX path of thePath
                
                -- Break if Tux Paint is chosen
                tell application "System Events"
                    if exists file (thePath & "/Contents/MacOS/Tux Paint") then      -- Old macOS
                        set thePath to thePath & "/Contents/Resources/share/tuxpaint/fonts"
                        exit repeat
                    else if exists file (thePath & "/Contents/MacOS/TuxPaint") then  -- New macOS
                        set thePath to thePath & "/Contents/Resources/share/tuxpaint/fonts"
                        exit repeat
                    else if exists file (thePath & "/tuxpaint") then                 -- iOS
                        set thePath to thePath & "/share/tuxpaint/fonts"
                        exit repeat
                    end if
                end tell

                -- Otherwise raise an error message then bring up the file chooser again
                ackDialog("Sorry, the selected application does not appear to be Tux Paint!")
            end repeat
        else
            ackDialog("We shouldn't get here: theTargetId=" & theTargetId)
        end if
        
        return thePath
    end fontsPathOf

    on install(thePath)
        set archivePath to POSIX path of (path to resource "tuxpaint-fonts.tar.gz")
        set quotedPath to quoted form of thePath
        set quotedArchivePath to quoted form of archivePath
        set isInstalled to false

        # -- Disable the buttons
        # disableButtons()

        -- Build the shell command to install the font set(s)
        set command to "mkdir -p " & quotedPath & " && tar xzvf " & quotedArchivePath & " -C " & quotedPath

        -- Try to install as user
        try
            do shell script command
            set isInstalled to true
        end try

        -- Otherwise try to install as admin
        if not isInstalled then
            do shell script command with administrator privileges
            set isInstalled to true
        end if

        -- Report status
        if isInstalled then
            ackDialog("The fonts have been successfully installed!")
        else
            ackDialog("Sorry, The fonts could not be installed.")
        end if

        -- Refresh the dialog box and the buttons
        refresh()
    end install

    on uninstall(thePath)
        set mainFontsFile to getMainFontsFile()
        set quotedPath to quoted form of (thePath & "/" & mainFontsFile)
        set command to "rm -f " & quotedPath
        set isRemoved to false

        # -- Disable the buttons
        # disableButtons()

        -- Try to remove as user
        try
            do shell script command
            set isRemoved to true
        end try

        -- Otherwise try to remove as admin
        if not isRemoved then
            do shell script command with administrator privileges
            set isRemoved to true
        end if

        -- Report status
        if isRemoved then
            ackDialog("The fonts have been successfully removed!")
        else
            ackDialog("Sorry, the fonts could not be removed.")
        end if

        -- Refresh the dialog box and the buttons
        refresh()
    end uninstall

    on ackDialog(message)
        display dialog message buttons {"OK"} default button 1 with icon 1
    end ackDialog
end script
