ConferenceTalk = Struct.new(:id, :created_at, :updated_at, :title, :speaker, :time, :description, :bio, keyword_init: true) do
  def resource_path
    "/conference_talks/#{id}"
  end
  
  def to_s
    "#{time}: #{title} by #{speaker})"
  end
end
