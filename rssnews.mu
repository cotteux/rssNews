#!/usr/bin/python3

# Required Modules
import feedparser, os, re, textwrap, urllib.parse, ipaddress, socket
from datetime import date, timedelta
from dateutil import parser
from os import environ

# Get Dates of Present and Previous Day's
today = date.today()
yesterday = today - timedelta(2)

print("`c`B166The RSS Reader`b`")
print("Choose your news feed ")
print("")
#print ('Input rss link `B500https://`B444`<30|user_input`>`b  `!`B500`[Go to link`:/page/rssnews.mu`user_input]`b')
print ('`!`[Tux Machine`:/page/rssnews.mu`resultat=http://news.tuxmachines.org/feed.xml] | `!`[Fox News`:/page/rssnews.mu`resultat=https://moxie.foxnews.com/google-publisher/latest.xml] | `!`[BBC News`:/page/rssnews.mu`resultat=https://feeds.bbci.co.uk/news/world/rss.xml] ')
print ('`!`[Wired`:/page/rssnews.mu`resultat=https://www.wired.com/feed/rss] | `!`[Hackers News`:/page/rssnews.mu`resultat=https://feeds.feedburner.com/TheHackersNews] | `!`[Tech Radar`:/page/rssnews.mu`resultat=https://www.techradar.com/feeds/articletype/news]')
print("")
print ("`B559`!`[Home`:/page/index.mu`page=Rss News]`b")

print("---")
print("``")

# Display the Parsed News
def display_news(title,summary,link):
        print("\n")
        print(">>"+title+"\n")
        for line in (textwrap.wrap(summary,width=70)): print(line.replace('`','+'))
        print("\n"+link)

# Get the date published of an Entry
def get_date(entries):
        dop = entries['published']
        dop_to_date = parser.parse(dop,ignoretz=True)
        dop_date = dop_to_date.date()
        return dop_date

# Get the title, link and summary of the news
def get_news(entries,noe,parsed_url):
        for i in range(0,noe):
                dop_date = get_date(entries[i])
                if  dop_date <= today and dop_date > yesterday :
                        title = entries[i]['title']
                        link = entries[i]['link']
                        summary = re.sub('<[^<]+?>','',str(entries[i]['summary']).replace('\n',''))
                        display_news(title,summary,link)

# Validate URL to prevent SSRF
def validate_url(url):
        parsed = urllib.parse.urlparse(url)
        if parsed.scheme not in ('http', 'https'):
                return False
        hostname = parsed.hostname
        try:
                addrs = socket.getaddrinfo(hostname, None)
                for addr in addrs:
                        ip = ipaddress.ip_address(addr[4][0])
                        if ip.is_private or ip.is_loopback or ip.is_link_local:
                                return False
        except Exception:
                return False
        return True

# Parse the URL's with feedparser
def parse_url(urls):
        for i in urls:
                if not validate_url(i):
                        print("`RInvalid or blocked URL`b")
                        continue
                parsed_url = feedparser.parse(i)
                entries = parsed_url.entries
                noe = len(entries)
                get_news(entries,noe,parsed_url)

# main

if environ.get("field_user_input") != None and environ.get("var_resultat") != None:
        os.environ['var_resultat'] =  environ.get("var_resultat")+"%09"+environ.get("field_user_input")


if environ.get("field_user_input") != None and environ.get("var_resultat") == None:
        os.environ['var_resultat'] =  environ.get("field_user_input")



if environ.get("var_resultat") != None:
        urls = [
                environ.get("var_resultat"),
        ]
        parse_url(urls)
        print("")
        print ("`B559`!`[RSS menu`:/page/index.mu`page=Rss News]`b")

