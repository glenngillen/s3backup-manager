%w{rubygems sinatra haml sass}.each do |lib|
  require lib
end

Dir["models/*"].each do |model|
  require model
end

get '/' do
  @buckets = Bucket.find_all
  haml :index
end

get '/new' do
  haml :new
end

post '/' do
  begin
    Bucket.create!(params[:collection_name])
    flash[:notice] = "Successfully created new backup collection"
    redirect "/"
  rescue AWS::S3::InvalidBucketName => exception
    flash[:error] = exception.message
    haml :new
  end
end

get '/:id' do
  haml :show
end

get '/:id/files' do
  haml :files
end

get '/:id/databases' do
  hamls :databases
end

get '/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

def flash
  session[:flash] = {} if session[:flash] && session[:flash].class != Hash
  session[:flash] ||= {}
end

template :layout do
%Q{
!!!
%html
  %head
    %title My Title Here
  %body
    - if flash
      - flash.each do |type,message|
        %p{ :class=> "message #{type}" }= message
      - flash.clear
    = yield
}
end