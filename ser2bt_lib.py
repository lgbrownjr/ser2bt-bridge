#!/usr/bin/python3

# -*- coding:utf-8 -*-
#import:
from PIL import Image, ImageDraw, ImageFont  # Font handeling
from waveshare_epd import epd2in13_V2

# Variable decleration
epd = epd2in13_V2.EPD()
#location
left_margin = 1 #Left margin.
top_margin = 11 #Will start all text at the 11th pixel
bottom_margen = epd.width - 1
line_position = top_margin #initial line to start on.
next_line_position = top_margin #initial line to start on.#location

def center_text(draw,msg,font):
    w, h = draw.textsize(msg, font)
    starting_point = (epd.height/2) - (w/2)
    return (starting_point)

def line_pos(new_page,draw,msg,font):
    global line_position
    global next_line_position
    w, h = draw.textsize(msg, font)
    if new_page is True:
        line_position = top_margin #initial line to start on.
        next_line_position = top_margin #initial line to start on.#location
    if next_line_position == top_margin:
        next_line_position = line_position + h
        return (line_position)
    else:
        line_position = next_line_position
        next_line_position = line_position + h
        return (line_position)
#exit()