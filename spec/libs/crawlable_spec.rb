shared_examples "a crawlable" do
    
  describe "#crawled?" do
    
    it "should be false when uncrawled for depth" do
      crawlable.crawled?(1).should be_false
    end
    
    it "should be false when expired" do
      crawlable.set_crawled_at(1, (Time.now - expiration - 1.second))
      crawlable.crawled?(1).should be_false
    end
    
    it "should be true otherwise" do
      crawlable.set_crawled_at(1, (Time.now - expiration + 1.second))
      crawlable.crawled?(1).should be_true
    end
    
  end
  
  describe "#crawl!" do
    
    it "should run the crawler" do
      crawlable.crawl!(:depth => 1)
      crawler.should have_queue_size_of(1)
      crawler.should have_queued({:id => crawlable.id, :depth => 1})
    end
    
    it "should set the default depth if not given as argument" do
      crawlable.crawl!
      crawler.should have_queue_size_of(1)
      crawler.should have_queued({:id => crawlable.id, :depth => default_depth})
    end
    
  end
  
  
  describe "set_crawled_at" do
    
    let(:time){ Time.now }
    let(:better_time){ time + 1.second }
    let(:worse_time){ time - 1.second }
    
    it "should set the crawl time for this depth" do
      crawlable.set_crawled_at(1, time)
      crawlable.crawl_dates[1].to_i.should == time.to_i
    end
    
    it "should propagate down if more recent" do
      crawlable.set_crawled_at(1, better_time)
      crawlable.set_crawled_at(2, worse_time)
      crawlable.set_crawled_at(3, time)
      
      crawlable.crawl_dates[1].to_i.should == better_time.to_i
      crawlable.crawl_dates[2].to_i.should == time.to_i
      crawlable.crawl_dates[3].to_i.should == time.to_i
    end
    
  end
  
end