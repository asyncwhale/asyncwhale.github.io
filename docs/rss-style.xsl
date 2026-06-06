<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:atom="http://www.w3.org/2005/Atom">
  <xsl:output method="html" version="5.0" encoding="utf-8" indent="yes"/>
  <xsl:template match="/">
    <html lang="zh-cn">
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title><xsl:value-of select="/rss/channel/title"/> · RSS 订阅源</title>
        <style>
          :root {
            --accent: #0d7c86; --bg: #fcfcfa; --card: #fff; --fg: #232321;
            --muted: #6b6b66; --border: #ebe9e4;
          }
          @media (prefers-color-scheme: dark) {
            :root { --accent: #63c8d4; --bg: #1a1b1e; --card: #222428; --fg: #cfcfcb;
                    --muted: #9a9a96; --border: #2c2e33; }
          }
          * { box-sizing: border-box; }
          body {
            margin: 0; background: var(--bg); color: var(--fg);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
            line-height: 1.7; -webkit-font-smoothing: antialiased;
          }
          .wrap { max-width: 720px; margin: 0 auto; padding: 3rem 1.4rem 4rem; }
          header { display: flex; align-items: baseline; gap: 0.7rem; flex-wrap: wrap; }
          .brand { font-size: 1.9rem; font-weight: 700; letter-spacing: -0.02em; }
          .tag {
            font-size: 0.72rem; letter-spacing: 0.08em; text-transform: uppercase;
            color: #fff; background: var(--accent); padding: 0.18rem 0.6rem; border-radius: 999px;
          }
          .note {
            margin: 1.5rem 0 2.5rem; padding: 1rem 1.2rem; font-size: 0.92rem;
            background: rgba(13, 124, 134, 0.08);
            background: color-mix(in srgb, var(--accent) 10%, transparent);
            border-left: 3px solid var(--accent); border-radius: 0 8px 8px 0; color: var(--muted);
          }
          .note strong { color: var(--fg); }
          .note code {
            font-family: ui-monospace, "SF Mono", Menlo, monospace; font-size: 0.85em;
            background: rgba(13, 124, 134, 0.13);
            background: color-mix(in srgb, var(--accent) 14%, transparent);
            padding: 0.1rem 0.35rem; border-radius: 5px; color: var(--fg);
          }
          .item { padding: 1.4rem 0; border-bottom: 1px solid var(--border); }
          .item-title {
            font-size: 1.3rem; font-weight: 600; letter-spacing: -0.01em;
            color: var(--fg); text-decoration: none;
          }
          .item-title:hover { color: var(--accent); }
          .item-date {
            font-family: ui-monospace, "SF Mono", Menlo, monospace;
            font-size: 0.78rem; color: var(--muted); margin-top: 0.35rem;
          }
          .item-desc { margin: 0.6rem 0 0; color: var(--muted); font-size: 0.95rem; }
          .item-desc p { margin: 0.4rem 0 0; }
          .item-desc p:first-child { margin-top: 0; }
          footer { margin-top: 2.5rem; font-size: 0.9rem; }
          footer a { color: var(--accent); text-decoration: none; }
          footer a:hover { text-decoration: underline; }
        </style>
      </head>
      <body>
        <div class="wrap">
          <header>
            <span class="brand">🐋 <xsl:value-of select="/rss/channel/title"/></span>
            <span class="tag">RSS 订阅源</span>
          </header>
          <div class="note">
            <strong>这是一个 RSS 订阅源</strong>，不是普通网页。把<strong>本页地址</strong>复制进你的 RSS 阅读器（Feedly、Reeder、NetNewsWire 等），以后有新文章会自动送到你眼前，不用回来手动刷。
            想了解 RSS？搜一下 <code>RSS 是什么</code> 就行。
          </div>
          <main>
            <xsl:for-each select="/rss/channel/item">
              <article class="item">
                <a class="item-title" href="{link}"><xsl:value-of select="title"/></a>
                <div class="item-date"><xsl:value-of select="substring(pubDate, 1, 16)"/></div>
                <div class="item-desc"><xsl:value-of select="description" disable-output-escaping="yes"/></div>
              </article>
            </xsl:for-each>
          </main>
          <footer>
            <a href="{/rss/channel/link}">← 回到 <xsl:value-of select="/rss/channel/title"/></a>
          </footer>
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
