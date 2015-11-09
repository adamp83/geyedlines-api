class UserPromptsController < ApplicationController
  def index
    @user_prompts = UserPrompt.all
  end

  def create
    @user_prompt = UserPrompt.new(params[:user_prompt].permit(:keyword, :body))
    if @user_prompt.save
      redirect_to user_prompts_path
    else
      # Fail...
    end
  end

  def show
  end

  def destroy
    @user_prompt = UserPrompt.find(params[:id])
    @user_prompt.destroy
    redirect_to user_prompts_path
  end
end
