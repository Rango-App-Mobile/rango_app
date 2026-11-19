"""Builds the Rango terms PDF from docs/termos-e-privacidade.md.

Usage (needs `pip install reportlab`, e.g. in a virtualenv):
    python3 tools/legal/make_terms_pdf.py . docs/termos-e-privacidade.pdf

The PDF is what goes to Google Drive and to the store listings.
"""

import re
import sys
from pathlib import Path

from reportlab.lib.colors import HexColor
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import ListFlowable, ListItem, Paragraph, SimpleDocTemplate, Spacer

root = Path(sys.argv[1])
out = sys.argv[2]
fonts = root / "assets" / "fonts"
pdfmetrics.registerFont(TTFont("Aleo", fonts / "aleo" / "Aleo-Regular.ttf"))
pdfmetrics.registerFont(TTFont("Aleo-Bold", fonts / "aleo" / "Aleo-Bold.ttf"))
pdfmetrics.registerFont(TTFont("Bowlby", fonts / "bowlby_one" / "BowlbyOne-Regular.ttf"))
pdfmetrics.registerFontFamily("Aleo", normal="Aleo", bold="Aleo-Bold")

INK = HexColor("#1B1B1E")
ACCENT = HexColor("#CA5F60")
MUTED = HexColor("#5C5C63")
CREAM = HexColor("#FFF8EE")

title = ParagraphStyle("title", fontName="Bowlby", fontSize=22, leading=27, textColor=INK, spaceAfter=6)
date = ParagraphStyle("date", fontName="Aleo", fontSize=9.5, leading=13, textColor=MUTED, spaceAfter=14)
h2 = ParagraphStyle("h2", fontName="Aleo-Bold", fontSize=13, leading=17, textColor=ACCENT, spaceBefore=14, spaceAfter=6)
body = ParagraphStyle("body", fontName="Aleo", fontSize=10.5, leading=15, textColor=INK, spaceAfter=7)


def inline(text: str) -> str:
    text = text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    return re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", text)


story = []
bullets = []


def flush_bullets():
    if bullets:
        story.append(
            ListFlowable(
                [ListItem(Paragraph(inline(b), body), leftIndent=12) for b in bullets],
                bulletType="bullet",
                bulletColor=ACCENT,
                start="•",
                leftIndent=12,
            )
        )
        bullets.clear()


md = (root / "docs" / "termos-e-privacidade.md").read_text(encoding="utf-8")
paragraph = []


def flush_paragraph():
    if paragraph:
        # Lines of one block (e.g. the contact) keep their own line.
        story.append(Paragraph("<br/>".join(inline(l) for l in paragraph), body))
        paragraph.clear()


for line in md.splitlines():
    if line.startswith("# "):
        story.append(Paragraph(inline(line[2:]), title))
    elif line.startswith("## "):
        flush_paragraph(); flush_bullets()
        story.append(Paragraph(inline(line[3:]), h2))
    elif line.startswith("- "):
        flush_paragraph()
        bullets.append(line[2:])
    elif line.startswith("Última atualização"):
        story.append(Paragraph(inline(line), date))
    elif not line.strip():
        flush_paragraph(); flush_bullets()
    else:
        paragraph.append(line)
flush_paragraph(); flush_bullets()


def page(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(CREAM)
    canvas.rect(0, 0, A4[0], A4[1], stroke=0, fill=1)
    canvas.setFont("Bowlby", 11)
    canvas.setFillColor(ACCENT)
    canvas.drawString(20 * mm, A4[1] - 14 * mm, "Rango")
    canvas.setFont("Aleo", 8.5)
    canvas.setFillColor(MUTED)
    canvas.drawRightString(A4[0] - 20 * mm, 12 * mm, f"Página {doc.page}")
    canvas.drawString(20 * mm, 12 * mm, "Termos de Uso e Política de Privacidade do Rango")
    canvas.restoreState()


doc = SimpleDocTemplate(
    out,
    pagesize=A4,
    leftMargin=20 * mm,
    rightMargin=20 * mm,
    topMargin=24 * mm,
    bottomMargin=22 * mm,
    title="Termos de Uso e Política de Privacidade do Rango",
    author="Antonio Costa",
    subject="Termos de Uso e Política de Privacidade",
)
doc.build(story, onFirstPage=page, onLaterPages=page)
