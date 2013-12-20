class UploadsController < ApplicationController
  
  before_filter :load_upload, only: [:update, :crop, :show, :destroy, :resize]

  def new 
    @upload = Upload.new
  end

  def create
    @upload = Upload.new(params[:upload])
    if @upload.save
      flash[:notice] = "Successfully Uploaded"
      redirect_to crop_upload_path(@upload)
    else
      render "new"
    end
  end

  def show
  end

  def update
    if @upload.update_attributes(params[:upload])
      flash[:notice] = "Successfully updated Upload."
      redirect_to @upload
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @upload.destroy
      flash[:notice] = "Successfully destroyed upload"
      redirect_to root_path
    else
      flash[:alert] = "Upload was not destroyed"
      redirect_to @upload
    end
  end

  def crop
  end

  def resize
    respond_to do |format|
      format.js { @upload.generate_thumbnails }
    end
  end

  private 

  def load_upload
    @upload = Upload.where(id: params[:id]).first
    unless @upload
      redirect_to root_path
    end
  end
end
