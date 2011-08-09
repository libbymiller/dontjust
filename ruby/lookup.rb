require 'rubygems'
require 'json/pure'
require 'net/http'
require 'uri'
require 'pp'
require 'hpricot'

# expand to use og

def lookup_url(u)

   u = u.sub(/\.$/,'')
   url = u
   title = u.to_s

   begin
     #puts "Checking url #{u}"
     url = URI.parse u
   rescue URI::InvalidURIError
     url = URI.parse u
   rescue URI::InvalidURIError
     puts "invalid uri"
     return u,title
   rescue Exception => e
     puts "problem checking url: #{e}"
     return u,title
   end
   req = Net::HTTP::Get.new(url.request_uri)
   begin
     res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
     body = res.body
     case res
     when Net::HTTPRedirection
       uu = res['Location']
       puts "Found a redirection"
       return lookup_url(uu)
     when Net::HTTPSuccess
       if body!=nil
         doc = Hpricot.XML(body.to_s)
         title = doc.at("title").innerHTML
         title = title.gsub("\n"," ")
         title = title.gsub("\r"," ") 
         title = title.gsub("\t"," ")
       else
         puts "BODY is nil #{body}"
       end
     
       if title==nil || title.strip=="" || title =~ /302 Found/
          title = url
       end
       return url, title   
     else
       puts "url is crud "+u
       return u,title
     end
   rescue SocketError
     puts "socket error"
     return u,title
   rescue Exception => f
     puts "exception fetching url: #{f}"
     return u,title
   end
          
end  
       
          
#puts lookup_url("http://www.imdb.com/title/tt0432283/")

