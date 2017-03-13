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
    data = data_in_search_file
    # Merge into existing hash appropriately.
    update_search_data(data,h)
    write_to_json data
  end

  def update_search_data(data,h)
    h.each do |k,v|
      if data[k].blank?
        data[k] = v
      else
        data[k].merge!(v)
      end
    end
  end

  def write_to_json data
    aFile = File.open("mini-search/search.json", "w")
    aFile.syswrite(data.to_json)
  end

  def data_in_search_file
    return nil unless File.exists?("mini-search/search.json")
    File.open("mini-search/search.json") do |f|
      data = JSON.parse(f.read) unless File.zero?("mini-search/search.json")
    end
  end

  def search
    result,final = {}, {}
    a, doc = [], []
    flag = true
    data = data_in_search_file
    binding.pry
    render json: {status: "No file has been indexed yet or the search.json file is missing. Please check the permissions."} and return if data.blank?
    queries = params[:queries].split(',')
    queries.each do |query|
      if flag
        flag = false
        a.push(data[query].keys).flatten
      else
        a = a.flatten & data[query].keys
      end
      result.merge!(data[query]) { |k,o,n| o+n }
    end
    result = result.sort_by { |k,v| v}.reverse.to_h
    result.slice!(*a) if params[:all].present?
    result.each_key { |key| doc.push(key.split("_").first)}
    doc.each do |i|
      aFile = File.read("mini-search/index_file_#{i}.txt")
      final.merge!({"article_#{i}": aFile})
    end
    render json: final
  end
end
