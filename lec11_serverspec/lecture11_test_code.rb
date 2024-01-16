require 'spec_helper'

# ホームとアプリディレクトリの指定
home_dir = "/home/ec2-user"
app_dir = "/home/ec2-user/raisetech-live8-sample-app"

# リッスンポートの指定
listen_port = "80"

# パッケージがインストールされているか確認 
describe package('nginx'), :if => os[:family] == 'amazon' do
  it { should be_installed }
end

#　複数パッケージの場合
%w{git gcc make}.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

# yarn
describe package('yarn') do
  it {should be_installed.by('npm')}
end

# rails & version
describe package('rails') do
  it { should be_installed.by('gem').with_version('7.0.4') }
end

# コマンドでrubyバージョンチェック
describe command('ruby -v') do
  its(:stdout) { should match /ruby 3\.1\.2/ }
end

# パスの確認
describe command('which mysql') do
  its(:exit_status) { should eq 0 }
end


# HTTP 200 OK 
describe command("curl http://127.0.0.1:#{listen_port} -o /dev/null -w \"%{http_code}\\n\" -s") do
  its(:stdout) { should match /^200$/ }
end

# EBS Size 
ebs_size ="8"

describe command("size=`df -h |grep /dev/xvda | awk '{printf (\"%4.0f\", $2)}'`; test $size -eq #{ebs_size}; echo $?") do
  its(:stdout) { should match "0" }
end

# Port 
describe port(listen_port) do
  it { should be_listening }
end

# サービス自動起動、実行中
describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

# MySQLソケット
describe file("#{app_dir}/config/database.yml") do
  socket_path = `mysql_config --socket`.chomp
  its(:content) { should match /socket:\s*#{Regexp.escape(socket_path)}/ }
end

# ディレクトリのパーミッションとオーナーの確認
describe file("#{home_dir}/.ssh") do
  it { should be_directory }
  it { should be_owned_by('ec2-user') }
  it { should be_grouped_into('ec2-user') }
  it { should be_mode '700' }
end