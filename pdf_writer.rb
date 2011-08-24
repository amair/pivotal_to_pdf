#!/usr/bin/env ruby

require 'rubygems'
require 'prawn'
require 'rainbow'
require "prawn/measurement_extensions"


class PdfWriter

  MARGIN = 5.mm

  attr_reader :story_or_iteration, :stories

  def initialize(story_or_iteration, colored_stripe = true)
    @story_or_iteration = story_or_iteration
    @stories = story_or_iteration.is_a?(Iteration) ? story_or_iteration.stories : [story_or_iteration]
    p stories.size
  end

  def write_to
    Prawn::Document.generate("#{story_or_iteration.id}.pdf",
                             :page_layout => :landscape,
                             :page_size => "A4",
                             :margin => [12.mm, 12.mm, 10.mm, 10.mm]) do |pdf|
      #:page_size   => [210.mm, 297.mm]) do |pdf|

      pdf.font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"

      index = 0

      stories.each do |story|

        if story.story_type != "release"

          bb = Hash.new
          bb = get_bounding_box(index %4)
#        bb.each do|name,val|
#          puts "#{name}: #{val}"
#        end

# --- Write content
          pdf.bounding_box [bb[:left], bb[:top]], :width => bb[:width], :height => bb[:height] do

            #        puts "top: #{pdf.bounds.absolute_top} left: #{pdf.bounds.absolute_left} right: #{pdf.bounds.absolute_right} bottom: #{pdf.bounds.absolute_bottom}"

            pdf.stroke_color = story.story_color unless story.story_color.nil?
            pdf.line_width=6
            pdf.stroke_bounds

            # We want to inset the text from the border which has been painted
            pdf.bounding_box [MARGIN, pdf.bounds.top-MARGIN], :width => 120.mm, :height => bb[:height] - MARGIN*2 do

#            puts "INSET top: #{pdf.bounds.absolute_top} left: #{pdf.bounds.absolute_left} right: #{pdf.bounds.absolute_right} bottom: #{pdf.bounds.absolute_bottom}"

#            pdf.stroke_color = "000000"
#            pdf.line_width=1
#            pdf.stroke_bounds

              pdf.text story.name, :size => 14
              pdf.fill_color "52D017"
              pdf.text story.label_text, :size => 8
              pdf.text "\n", :size => 14
              pdf.fill_color "444444"
              pdf.text story.description || "", :size => 10
              pdf.fill_color "000000"

              pdf.text_box story.points, :size => 12, :align => :center, :valign => :bottom unless story.points.nil?
              pdf.text_box "Owner: " + (story.respond_to?(:owned_by) ? story.owned_by : "None"), :size => 8, :valign => :bottom

              pdf.fill_color "999999"
              pdf.text_box story.story_type.capitalize, :size => 8, :align => :right, :valign => :bottom
              pdf.fill_color "000000"
            end
          end
          index = index + 1
        end

        if (index % 4) == 0
          pdf.start_new_page unless index == stories.size - 1
        end
      end
      pdf.number_pages "<page>/<total>", {:at => [pdf.bounds.right - 16, -28]}

      puts ">>> Generated PDF file in '#{story_or_iteration.id}.pdf'".foreground(:green)
    end
  rescue Exception
    puts "[!] There was an error while generating the PDF file... What happened was:".foreground(:red)
    raise
  end

  def get_bounding_box(position)
    case (position)
      when 0
        {:top => 200.mm, :left => 12.mm, :width => 130.mm, :height => 90.mm}
      when 1
        {:top => 200.mm, :left => 155.mm, :width => 130.mm, :height => 90.mm}
      when 2
        {:top => 100.mm, :left => 12.mm, :width => 130.mm, :height => 90.mm}
      when 3
        {:top => 100.mm, :left => 155.mm, :width => 130.mm, :height => 90.mm}
      else
        {:top => 0.mm, :left => 0.mm, :width => 130.mm, :height => 90.mm}
    end
  end
end
