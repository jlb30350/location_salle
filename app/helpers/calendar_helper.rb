# app/helpers/calendar_helper.rb

module CalendarHelper
    def generate_calendar(year, month)
      start_date = Date.new(year, month, 1)
      end_date = start_date.end_of_month
      current_date = start_date
  
      content_tag :table, class: 'calendar' do
        content_tag(:thead) do
          content_tag(:tr) do
            %w[Mon Tue Wed Thu Fri Sat Sun].each do |day|
              concat content_tag(:th, day)
            end
          end
        end +
        content_tag(:tbody) do
          rows = ''.html_safe
          while current_date <= end_date
            rows << content_tag(:tr) do
              week = ''.html_safe
              7.times do
                if current_date.month == month
                  week << content_tag(:td, current_date.day)
                else
                  week << content_tag(:td, '')
                end
                current_date += 1.day
              end
              week
            end
          end
          rows
        end
      end
    end
  end
  