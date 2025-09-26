class SessionsController < ApplicationController
  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out!"
  end

  def spotify
    auth = request.env["omniauth.auth"]
    rspotify_user = RSpotify::User.new(auth)

    # Find or create local user
    @user = User.find_or_create_by(spotify_id: rspotify_user.id) do |u|
      u.email = rspotify_user.email
      u.name  = rspotify_user.display_name || rspotify_user.id
    end

    # Save the RSpotify auth info in session for future API calls
    session[:spotify_user] = rspotify_user.to_hash
    session[:user_id] = @user.id

    # Sync playlists into our database
    sync_playlists(@user, rspotify_user)

    redirect_to root_path, notice: "Logged in with Spotify!"
  end

  private

  def sync_playlists(user, rspotify_user)
    offset = 0
    loop do
      batch = rspotify_user.playlists(limit: 50, offset: offset)
      break if batch.empty?

      batch.each do |playlist|
        user.playlists.find_or_create_by(spotify_id: playlist.id) do |p|
          p.name        = playlist.name
          p.track_count = playlist.tracks.size
        end
      end

      offset += 50
    end
  end
end
