class MoviesController < ApplicationController

  @@total_count = 1

  def create
    # binding.pry
    Dir.mkdir("mini-search") unless File.exists?("mini-search")
    aFile = File.open("mini-search/index_file_#{@@total_count}.txt", "w")
    if aFile
      aFile.syswrite(params[:content])
      inverted_index(params[:content])
      render json: { status: "ok" }, status: :ok
    else
      render json: { status: "unprocessable_entity" }, status: :unprocessable_entity
    end
    @@total_count += 1
  end

  def inverted_index(content)
    # binding.pry
    ii = filtered_content(content)
    h = make_hash(ii)
    # storing term frequency in hash as well.
    h.each { |k,v| h[k] = {"#{@@total_count}_score": v} }
    append_in_existing(h)


  end

  def filtered_content(content)
    # binding.pry

    word_array = content.split()
    word_array = word_array - Movie::FILTERING_LIST
  end

  def make_hash( array )
    # binding.pry

    hash = Hash.new(0)
    array.each{|key| hash[key] += 1}
    hash
  end

  def append_in_existing(h)
    data = {}
    File.open("mini-search/search.json") do |f|
      data = JSON.parse(f.read) unless File.zero?("mini-search/search.json")
    end
    # Merge into existing hash appropriately.
    h.each do |k,v|
      if data[k].blank?
        data[k] = v
      else
        data[k].merge!(v)
      end
    end
    aFile = File.open("mini-search/search.json", "w")
    aFile.syswrite(data.to_json)
  end

  def input

  end

  def search
  end
end
