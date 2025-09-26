class PagesController < ApplicationController
  def index
    if current_user
      @playlists = current_user.playlists
    else
      @playlists = []
    end
  end
end
