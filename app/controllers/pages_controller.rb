class PagesController < ApplicationController
  def home
    # Retrieve only guides which are "kept" (ie. have not been archived using the Discard gem), limited to the most 
    # recently-published 3 guides using the custom Guide scope "recent".
    # Use "includes" to eager load user, tags and guide_tags associations, whose attributes are displayed in the view.
    @recent_guides = Guide.includes(%i[user tags guide_tags]).kept.recent(3)
    # Retrieve only guides owned by the current user, limited to the 3 most recently published.  Use "includes" to eager
    # load the user to which the guide belongs and the guide's guide_tags and tags associations, which are used in the view.
    @owned_guides = current_user.owned_guides.recent(3).includes(:user, :guide_tags, :tags) if user_signed_in?
    # Retrieve only guides created by the current user, limited to the most recently-published 3 guides.
    # Use "includes" to eager load the Guide's user, guide_tags and tags associations, which are used in the view.
    @published_guides = current_user.guides.recent(3).includes(:user, :guide_tags, :tags) if user_signed_in?
  end
end
