Pod::Spec.new do |s|
s.name = 'WJXFMDB'
s.version = '1.0.0'
s.license = 'MIT'
s.summary = '数据库'
s.description = 'FMDB帮助类,便于我们对数据操作,支持模型存储,查询返回对应模型!'
s.homepage = 'https://github.com/wangjixiao1992/WJXFMDB'
s.authors = {'wangjixiao' => '642907599@qq.com' }
s.source = {:git => "https://github.com/wangjixiao1992/WJXFMDB.git", :tag => "v1.0.0"}
s.source_files  = "**/*.{h,m}"
s.platform = :ios, "8.0"
s.requires_arc = false
s.dependency = “FMDB”
end
