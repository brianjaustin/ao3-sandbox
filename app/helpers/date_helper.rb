module DateHelper

  # Use time_ago_in_words if less than a month ago, otherwise display date
  def set_format_for_date(datetime)
    return "" unless datetime.is_a? Time
    if datetime > 30.days.ago && !AdminSetting.enable_test_caching?
      time_ago_in_words(datetime)
    else
      date_in_user_time_zone(datetime).to_date.to_formatted_s(:rfc822)
    end
  end

  def date_in_user_time_zone(datetime)
    if logged_in? && current_user.preference.time_zone
      zone = current_user.preference.time_zone
      begin
        date_in_user_time_zone = datetime.in_time_zone(current_user.preference.time_zone)
      rescue
        datetime
      end
    else
      date_in_user_time_zone = datetime
    end
  end

  # show date in the time zone specified
  # note: this does *not* append timezone and does *not* reflect user preferences
  def date_in_zone(time, zone = nil)
    zone ||= Time.zone.name
    return nil if time.blank?

    time_in_zone = time.in_time_zone(zone)
    I18n.l(time_in_zone, format: :date_short_html).html_safe
    # i18n-tasks-use t('time.formats.date_short_html')
  end
end
