class SoundsController < ApplicationController
  # /sounds/:filename に来たリクエストを public/sounds から返す
  def show
    base = params[:filename]
    # 常に .mp3 を付けて探す（public/sounds/<filename>.mp3）
    filename = "#{base}.mp3"

    # ディレクトリトラバーサル防止
    return head :bad_request if filename&.include?("/")

    path = Rails.root.join("public", "sounds", filename)
    send_file path, type: "audio/mpeg", disposition: "inline"
  end
end
