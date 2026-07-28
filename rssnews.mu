#!/usr/bin/python3

import os, re, textwrap, socket, ssl
from datetime import date, timedelta
from dateutil import parser
from urllib.parse import urlparse
from urllib.request import Request, urlopen, HTTPRedirectHandler, build_opener
import ipaddress
import feedparser

today = date.today()
yesterday = today - timedelta(2)

def display_news(title, summary, link):
    print("\n")
    print(">>" + title + "\n")
    for line in textwrap.wrap(summary, width=70):
        print(line.replace('`', '+'))
    print("\n" + link)

def get_date(entry):
    dop = entry['published']
    dop_to_date = parser.parse(dop, ignoretz=True)
    return dop_to_date.date()

def get_news(entries, noe):
    for i in range(noe):
        dop_date = get_date(entries[i])
        if dop_date <= today and dop_date > yesterday:
            title = entries[i]['title']
            link = entries[i]['link']
            summary = re.sub('<[^<]+?>', '', str(entries[i]['summary']).replace('\n', ''))
            display_news(title, summary, link)

def resolve_and_validate(url):
    parsed = urlparse(url)
    if parsed.scheme not in ('http', 'https'):
        return None
    hostname = parsed.hostname
    if not hostname:
        return None
    try:
        addrs = socket.getaddrinfo(hostname, None)
        for addr in addrs:
            ip = ipaddress.ip_address(addr[4][0])
            if ip.is_private or ip.is_loopback or ip.is_link_local or ip.is_multicast:
                return None
    except Exception:
        return None
    return parsed

class SafeRedirectHandler(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        if not resolve_and_validate(newurl):
            raise Exception("Blocked redirect to unsafe URL")
        return super().redirect_request(req, fp, code, msg, headers, newurl)

def fetch_and_parse(url):
    if not resolve_and_validate(url):
        return None
    ctx = ssl.create_default_context()
    ctx.check_hostname = True
    ctx.verify_mode = ssl.CERT_REQUIRED
    opener = build_opener(SafeRedirectHandler)
    req = Request(url, headers={'User-Agent': 'RSSReader/1.0'})
    try:
        resp = opener.open(req, timeout=15)
        raw = resp.read()
        return feedparser.parse(raw)
    except Exception:
        return None

def main():
    feed_url = None
    if os.environ.get("var_resultat"):
        feed_url = os.environ.get("var_resultat")
    elif os.environ.get("field_user_input"):
        feed_url = os.environ.get("field_user_input")

    if not feed_url:
        return

    parsed_feed = fetch_and_parse(feed_url)
    if not parsed_feed:
        print("`RFailed to fetch or parse feed`b")
        return

    entries = parsed_feed.entries
    get_news(entries, len(entries))
    print("")
    print("`B559`!`[RSS menu`:/page/index.mu`page=Rss News]`b")

if __name__ == "__main__":
    print("`c`B166The RSS Reader`b`")
    print("Choose your news feed ")
    print("")
    print('`!`[Tux Machine`:/page/rssnews.mu`resultat=http://news.tuxmachines.org/feed.xml] | `!`[Fox News`:/page/rssnews.mu`resultat=https://moxie.foxnews.com/google-publisher/latest.xml] | `!`[BBC News`:/page/rssnews.mu`resultat=https://feeds.bbci.co.uk/news/world/rss.xml] ')
    print('`!`[Wired`:/page/rssnews.mu`resultat=https://www.wired.com/feed/rss] | `!`[Hackers News`:/page/rssnews.mu`resultat=https://feeds.feedburner.com/TheHackersNews] | `!`[Tech Radar`:/page/rssnews.mu`resultat=https://www.techradar.com/feeds/articletype/news]')
    print("")
    print("`B559`!`[Home`:/page/index.mu`page=Rss News]`b")
    print("---")
    print("``")
    main()
