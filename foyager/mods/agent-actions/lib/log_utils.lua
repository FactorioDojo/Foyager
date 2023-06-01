-- Custom log
-- Print log to file with message_id attached for easier scraping
function clog(msg)
    log("Message ID: " .. global["message_id"] .. " " ..msg)
end