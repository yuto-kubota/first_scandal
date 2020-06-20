class ScandalsController < ApplicationController
  require 'line/bot'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

def find_videos(keyword)
  service = Google::Apis::YoutubeV3::YouTubeService.new
  service.key = ENV["YOUTUBEKEY"]

  next_page_token = nil
  opt = {
    q: keyword,
    type: 'video',
    channel_id: 'UCSNX8VGaawLFG_bAZuMyQ3Q',
    max_results: 11,
    order: :date,
    page_token: next_page_token
  }
  service.list_searches(:snippet, opt)
end


 def template
   number = 0
   ran = rand(1..11)
   youtube = find_videos('SCANDAL')
   youtube.items.each do |item|
     number = number + 1
     if number == ran
       @youtube_data = item
     end
   end

   image = @youtube_data.snippet.thumbnails.default.url
   youtube_url = "https://www.youtube.com/embed/#{@youtube_data.id.video_id}"
{
 "type": "bubble",
 "hero": {
   "type": "image",
   "url": image,
   "size": "full",
   "aspectRatio": "20:13",
   "aspectMode": "cover"
 },
 "body": {
   "type": "box",
   "layout": "vertical",
   "contents": [
     {
       "type": "text",
       "text": "SCANDAL",
       "weight": "bold",
       "size": "xl"
     }
   ]
 },
 "footer": {
   "type": "box",
   "layout": "vertical",
   "spacing": "sm",
   "contents": [
     {
       "type": "button",
       "style": "link",
       "height": "sm",
       "action": {
         "type": "uri",
         "label": "YouTube",
         "uri": youtube_url
       }
     }
   ]
 }
}


 end

 def callback
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each do |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        client.reply_message(event['replyToken'],template )
      end
    end
  end
  # Don't forget to return a successful response
  "OK"
 end


end
