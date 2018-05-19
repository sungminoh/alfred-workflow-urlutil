on isRunning(appName)
    tell application "System Events" to (name of processes) contains appName
end isRunning


on split(theString, theDelimiter)
    set oldDelimiters to AppleScript's text item delimiters
    set AppleScript's text item delimiters to theDelimiter
    set theArray to text items of theString
    set AppleScript's text item delimiters to oldDelimiters
    return theArray
end split 


on getDefaultBrowser()
    tell application "Finder"
        set pwd to POSIX path of ((path to me as text) & "::")
        set htmlFile to pwd & "dummy.html"
        set defaultBrowser to default application of (info for POSIX path of htmlFile) as text
        set defaultBrowser to my split(defaultBrowser, ":")
        set defaultBrowser to item 3 of defaultBrowser
        set defaultBrowser to my split(defaultBrowser, ".")
        set defaultBrowser to item 1 of defaultBrowser
    end tell
    return defaultBrowser
end getDefaultBrowser


tell application "System Events" to set frontApp to name of first process whose frontmost is true


if (frontApp = "Safari") or (frontApp = "Webkit") then
    using terms from application "Safari"
        tell application frontApp to set currentTabUrl to URL of front document
        tell application frontApp to set currentTabTitle to name of front document
    end using terms from
else if (frontApp = "Google Chrome") or (frontApp = "Google Chrome Canary") or (frontApp = "Chromium") then
    using terms from application "Google Chrome"
        tell application frontApp to set currentTabUrl to URL of active tab of front window
        tell application frontApp to set currentTabTitle to title of active tab of front window
    end using terms from
else
    set defaultBrowser to getDefaultBrowser()
    if application defaultBrowser is running then
        set defaultRunning to 1
    end if
    if defaultRunning = 1 and ((defaultBrowser = "Google Chrome") or (defaultBrowser = "Google Chrome Canary") or (defaultBrowser = "Chromium")) then
        using terms from application "Google Chrome"
            tell application defaultBrowser to set currentTabUrl to URL of active tab of front window
            tell application defaultBrowser to set currentTabTitle to title of active tab of front window
        end using terms from
    else if defaultRunning = 1 and ((defaultBrowser = "Safari") or (defaultBrowser = "Webkit")) then
        using terms from application "Google Chrome"
            tell application defaultBrowser to set currentTabUrl to URL of front document
            tell application defaultBrowser to set currentTabTitle to name of front document
        end using terms from
    else if isRunning("Google Chrome") or isRunning("Google Chrome Canary") or isRunning("Chromium") then
        using terms from application "Google Chrome"
            tell application defaultBrowser to set currentTabUrl to URL of active tab of front window
            tell application defaultBrowser to set currentTabTitle to title of active tab of front window
        end using terms from
    else if isRunning("Safari") or isRunning("Webkit") then
        using terms from application "Google Chrome"
            tell application defaultBrowser to set currentTabUrl to URL of front document
            tell application defaultBrowser to set currentTabTitle to name of front document
        end using terms from
    end if
end if


on escapeXml(toEscape)
	set res to replaceChars(toEscape, "&", "&amp;")
	set res to replaceChars(res, "'", "&apos;")
	set res to replaceChars(res, ">", "&gt;")
	set res to replaceChars(res, "<", "&lt;")
    set res to replaceChars(res, "\"", "&quot;")
	return res
end escapeXml


on replaceChars(inputText, searchString, replacementString)
    set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to the searchString
	set the itemList to every text item of inputText
	set AppleScript's text item delimiters to the replacementString
	set inputText to the itemList as string
    set AppleScript's text item delimiters to oldDelimiters
	return inputText
end replaceChars


on alfredItem(arg, title, subtitle)
    return "<item arg=\"" & escapeXml(arg) & "\"><title>" & escapeXml(title) & "</title><subtitle>" & escapeXml(subtitle) & "</subtitle><text type=\"copy\">" & escapeXml(subtitle) & "</text></item>"
end alfredItem


on alfreadWorkflow(currentTabTitle, currentTabUrl, shortenUrl)
    set header to "<?xml version=\"1.0\"?><items>"
    set itemShortenUrl to alfredItem(shortenUrl, "Shorten URL", shortenUrl)
    set itemUrl to alfredItem(currentTabUrl, "URL", currentTabUrl)
    set itemTitle to alfredItem(currentTabTitle, "Title", currentTabTitle)
    set anchor to "<a href=\"" & currentTabUrl & "\">" & currentTabTitle & "</a>"
    set itemAnchor to alfredItem(anchor, "Anchor", anchor)
    set markdown to "[" & currentTabTitle & "]" & "(" & currentTabUrl & ")"
    set itemMarkdown to alfredItem(markdown, "Markdown", markdown)
    set footer to "</items>"
    return header & itemShortenUrl & itemUrl & itemTitle & itemAnchor & itemMarkdown & footer
end alfreadWorkflow

set shortenUrl to do shell script "curl https://tinyurl.com/api-create.php?url='" & currentTabUrl & "'"

return alfreadWorkflow(currentTabTitle, currentTabUrl, shortenUrl)
