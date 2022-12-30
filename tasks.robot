*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.FileSystem
Library    RPA.Archive
Library    RPA.Dialogs
Library    RPA.Robocorp.Vault

*** Variables ***    
#${CSV_link}    https://robotsparebinindustries.com/orders.csv
${Bots_folder}    ${OUTPUT_DIR}${/}Bot_Receipts
${Orders_file}    ${OUTPUT_DIR}${/}Orders_file${/}orders.csv
${OK_button}    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
${Legs_field}    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input
${Preview_button}    id:preview
${Preview_image}    id:robot-preview-image
${Order_button}    id:order
${Receipt_class}    class:badge

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${Bot_link}=    Input dialog
    Download CSV file
    Open bot order website    ${Bot_link}
    ${Bot_List}=    Read table from CSV    ${Orders_file}    header=True
    FOR    ${bot}    IN    @{Bot_List}
        Select bot parts    ${bot}
        Preview selected bot
        Wait Until Keyword Succeeds    10x    3 sec    Order bot    #Order robots from RobotSpareBin Industries Inc
        ${pdf}=    Export receipt to PDF    ${bot}[Order number]    #Saves the order HTML receipt as a PDF file.
        ${img}=    Screenshot bot beauty    ${bot}[Order number]    #Saves the screenshot of the ordered robot.
        Embed bot image to its pdf    ${img}    ${pdf}    #Embeds the screenshot of the robot to the PDF receipt.
        Next bot
    END
    ZIP receipt files    #Creates ZIP archive of the receipts and the images.
    [Teardown]    Close browser
    

*** Keywords ***
Input dialog
    Add heading    Inform the Bot Store website
    Add text input    bot_store    label=Bot Store    placeholder=Type here the website
    ${result}=    Run dialog
    Return From Keyword    ${result}[bot_store]

Download CSV file
    ${CSV_link}=    Get Secret    CSV_link
    Download    ${CSV_link}[CSV_link]    target_file=${Orders_file}    overwrite=True
    

Open bot order website
    [Arguments]    ${Bot_link}
    Open Available Browser       ${Bot_link}
    Wait Until Page Contains Element    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1] 
        

Select bot parts
    [Arguments]    ${bot}
    Click Element When Visible    ${OK_button}
    Select From List By Value    head    ${bot}[Head]
    Select Radio Button    body    ${bot}[Body]
    Input Text   ${Legs_field}    ${bot}[Legs]
    Input Text    address    ${bot}[Address]
    

Preview selected bot
    Click Button    ${Preview_button}
    Wait Until Element Is Visible    ${Preview_image}


Order bot
    Click Button    ${Order_button}
    Wait Until Page Contains Element    class:badge

Export receipt to PDF
    [Arguments]    ${Order}
    ${ReceiptAtt}=    Get Element Attribute    ${Receipt_class}    outerHTML
    Html To Pdf    ${ReceiptAtt}    ${Bots_folder}${/}receipt_${Order}.pdf
    Wait Until Created    ${Bots_folder}${/}receipt_${Order}.pdf
    Return From Keyword    ${OUTPUT_DIR}${/}Bot_Receipts${/}receipt_${Order}.pdf

Screenshot bot beauty
    [Arguments]    ${Order}  
    Screenshot    id:robot-preview-image    ${Bots_folder}${/}Images${/}bot_${Order}.png
    Return From Keyword    ${OUTPUT_DIR}${/}Bot_Receipts${/}Images${/}bot_${Order}.png

Embed bot image to its pdf
    [Arguments]    ${img}    ${pdf}
    ${files}=    Create List
    ...    ${img}:align=center
    Add Files to PDF    ${files}    ${pdf}    append=true


Next bot
    Wait Until Element Is Visible    class:badge
    Click Button    id:order-another


ZIP receipt files
    ${zip_name}=    Set Variable    ${OUTPUT_DIR}${/}Bot_Receipts${/}Receipts.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}Bot_Receipts    ${zip_name}    recursive=true 

