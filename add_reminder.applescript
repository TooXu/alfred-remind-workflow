-- Alfred Workflow to add reminders to macOS Reminders app
-- Usage: ./add_reminder.applescript "Reminder text" ["List name"]

on run argv
    set reminderText to item 1 of argv
    
    -- Default list is "提醒事项" (default Reminders list in Chinese)
    set listName to "提醒事项"
    
    -- If a second argument is provided, use it as the list name
    if (count of argv) > 1 then
        set listName to item 2 of argv
    end if
    
    -- Parse list name and reminder text
    set {parsedListName, cleanReminderText} to parseListName(reminderText)
    
    -- If a list name was found in the text, use it instead
    if parsedListName is not missing value then
        set listName to parsedListName
        set reminderText to cleanReminderText
    end if
    
    -- Parse date and time from the reminder text
    set {reminderTitle, reminderDate} to parseReminderText(reminderText)
    
    tell application "Reminders"
        -- Make sure the app is running
        activate
        
        -- Find the specified list, or use the default list if not found
        try
            set targetList to list listName
        on error
            -- Try to find a list that contains the specified name
            set foundList to missing value
            set allLists to every list
            repeat with aList in allLists
                set listTitle to name of aList as string
                if listTitle contains listName then
                    set foundList to aList
                    exit repeat
                end if
            end repeat
            
            if foundList is not missing value then
                set targetList to foundList
            else
                set targetList to default list
            end if
        end try
        
        -- Create a new reminder
        tell targetList
            set newReminder to make new reminder with properties {name:reminderTitle}
            
            -- Set the due date if one was parsed
            if reminderDate is not missing value then
                set due date of newReminder to reminderDate
            end if
        end tell
        
        -- Return success message
        return "已添加提醒：" & reminderTitle & "（添加到列表：" & (name of targetList) & "）"
    end tell
end run

-- Function to parse list name from reminder text
on parseListName(theText)
    -- Common list names from the screenshot
    set knownLists to {"提醒", "提醒事项", "立马做", "稍后做", "找人做", "可不做"}
    set foundList to missing value
    set cleanText to theText
    
    -- Check if text contains list specifier
    if theText contains "@" then
        set AppleScript's text item delimiters to "@"
        set textItems to text items of theText
        
        -- If we have at least 2 items, the second one should contain the list name
        if (count of textItems) > 1 then
            set listPart to text item 2 of textItems
            
            -- Extract list name (everything up to the next space or end of string)
            set AppleScript's text item delimiters to space
            set listNameItems to text items of listPart
            
            if (count of listNameItems) > 0 then
                set potentialListName to text item 1 of listNameItems
                
                -- Check if it's one of our known lists or use as is
                set foundList to potentialListName
                
                -- Remove the list specifier from the original text
                if (count of listNameItems) > 1 then
                    -- There's more text after the list name, so keep that part
                    set remainingText to ""
                    repeat with i from 2 to count of listNameItems
                        set remainingText to remainingText & space & (text item i of listNameItems)
                    end repeat
                    set cleanText to (text item 1 of textItems) & remainingText
                else
                    -- The list name was the only thing after @
                    set cleanText to text item 1 of textItems
                end if
            end if
        end if
    end if
    
    -- Trim whitespace from the clean text
    set cleanText to trimText(cleanText)
    
    return {foundList, cleanText}
end parseListName

-- Function to parse reminder text and extract date/time information
on parseReminderText(theText)
    -- Common Chinese time expressions
    set today to current date
    set tomorrow to today + (24 * 60 * 60) -- 24 hours in seconds
    
    set reminderTitle to theText
    set reminderDate to missing value
    
    -- Check for common time patterns in Chinese
    if theText contains "今天" then
        set reminderDate to today
        set reminderTitle to my replaceText(theText, "今天", "")
    else if theText contains "明天" then
        set reminderDate to tomorrow
        set reminderTitle to my replaceText(theText, "明天", "")
    else if theText contains "后天" then
        set reminderDate to tomorrow + (24 * 60 * 60)
        set reminderTitle to my replaceText(theText, "后天", "")
    end if
    
    -- Check for time patterns like "下午3点" or "晚上8点"
    if reminderDate is not missing value then
        -- Morning (上午)
        if reminderTitle contains "上午" then
            set hourText to extractHourFromText(reminderTitle, "上午")
            if hourText is not missing value then
                set hourNum to hourText as integer
                set hours of reminderDate to hourNum
                set minutes of reminderDate to 0
                set reminderTitle to my replaceText(reminderTitle, "上午" & hourText & "点", "")
            end if
        -- Afternoon (下午)
        else if reminderTitle contains "下午" then
            set hourText to extractHourFromText(reminderTitle, "下午")
            if hourText is not missing value then
                set hourNum to hourText as integer
                set hours of reminderDate to hourNum + 12
                set minutes of reminderDate to 0
                set reminderTitle to my replaceText(reminderTitle, "下午" & hourText & "点", "")
            end if
        -- Evening (晚上)
        else if reminderTitle contains "晚上" then
            set hourText to extractHourFromText(reminderTitle, "晚上")
            if hourText is not missing value then
                set hourNum to hourText as integer
                if hourNum < 12 then
                    set hours of reminderDate to hourNum + 12
                else
                    set hours of reminderDate to hourNum
                end if
                set minutes of reminderDate to 0
                set reminderTitle to my replaceText(reminderTitle, "晚上" & hourText & "点", "")
            end if
        end if
    end if
    
    -- Trim whitespace from the title
    set reminderTitle to trimText(reminderTitle)
    
    return {reminderTitle, reminderDate}
end parseReminderText

-- Helper function to extract hour from text
on extractHourFromText(theText, timePrefix)
    set AppleScript's text item delimiters to timePrefix
    set textItems to text items of theText
    if (count of textItems) > 1 then
        set hourPart to text item 2 of textItems
        set AppleScript's text item delimiters to "点"
        set hourText to text item 1 of hourPart
        -- Check if hourText is a number
        try
            set hourNum to hourText as integer
            return hourText
        on error
            return missing value
        end try
    end if
    return missing value
end extractHourFromText

-- Helper function to replace text
on replaceText(theText, searchString, replacementString)
    set AppleScript's text item delimiters to searchString
    set textItems to text items of theText
    set AppleScript's text item delimiters to replacementString
    return textItems as text
end replaceText

-- Helper function to trim whitespace
on trimText(theText)
    -- Remove leading whitespace
    repeat while theText begins with " "
        set theText to text 2 thru end of theText
    end repeat
    
    -- Remove trailing whitespace
    repeat while theText ends with " "
        set theText to text 1 thru ((length of theText) - 1) of theText
    end repeat
    
    return theText
end trimText
