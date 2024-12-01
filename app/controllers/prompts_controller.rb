class PromptsController < ApplicationController
  def index
    @prompt = Prompt.new
  end

  def rspec
    @prompt = Prompt.new
  end

  def rubocop
    @prompt = Prompt.new
  end
end
