#!/usr/bin/python3

# Required Modules
import feedparser, re, textwrap
from datetime import date, timedelta
from dateutil import parser

# Get Dates of Present and Previous Day's
today = date.today()
yesterday = today - timedelta(2)

print("`cRSS News")
print(50*"=")

# Display the Parsed News
def display_news(title,summary,link):
        print("``\n")
        print(">"+title+"\n")
        for line in (textwrap.wrap(summary,width=70)): print(line)
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

# Parse the URL's with feedparser
def parse_url(urls):
        for i in urls:
                parsed_url = feedparser.parse(i)
                entries = parsed_url.entries
                noe = len(entries)
                get_news(entries,noe,parsed_url)

# main
if __name__ == "__main__":
        urls = [
                'https://feeds.feedburner.com/TheHackersNews',
        ]
        parse_url(urls)

