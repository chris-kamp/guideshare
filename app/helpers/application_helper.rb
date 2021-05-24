module ApplicationHelper

  # User to display a price in currency, or "Free" if price is zero
  def display_price(guide)
    return guide.free? ? "Free" : number_to_currency(guide.price, locale: :en)
  end

  # Used to display a guide's author's username, appending "(you)" if current user is author
  def display_author(guide)
    name = guide.user.username
    return guide.authored_by?(user_or_guest) ? "#{name} (you)" : name
  end

  # Used to display a list of a guide's tags in a comma-separated format
  def display_guide_tags(guide)
    guide.tags.map(&:name).join(", ")
  end

  # Returns the description for a guide if not empty, or else "no description provided"
  def description_text(guide)
    return guide.description.blank? ? "No description provided" : guide.description
  end

  # Used to display the number of users who have purchased a guide, using Rails pluralize helper for inflection
  def display_owners_count(guide)
    users = guide.owners_count
    return "#{pluralize(users, 'user')} #{'has'.pluralize(users)} purchased this guide"
  end

  # If referer location is set and is not the current page (to avoid infinite loop), link to it.
  # Otherwise, link to a given fallback location.
  def link_back(fallback)
    back = request.referer.present? && request.referer != request.url ? request.referer : fallback
    return link_to("Back", back)
  end

  # Given a guide rating, format it for display
  def display_rating(rating)
    return rating.nil? ? "Free" : number_with_precision(rating, precision: 2)
  end
end
