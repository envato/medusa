require 'spec_helper'

require_relative '../lib/medusa/keeper'

describe Medusa::Keeper do
  subject(:keeper) { described_class.new }
  let(:overlord) { double("Overlord") }
  let(:dungeon) { double("Dungeon", fit_out!: union) }
  let(:union) { double("Union") }
  let(:plan) { Medusa::DungeonPlan.new }

  describe "#serve!" do
    it "is named by the Overlord" do
      keeper.serve!(overlord, "Barry", plan)
      expect(keeper.name).to eql "Barry"
    end

    it "serves the Overlord" do
      keeper.serve!(overlord, "Barry", plan)
      expect(keeper.overlord).to eql overlord
    end
  end

  describe "#claim!" do
    it "fit outs the dungeon" do
      keeper.claim!(dungeon)
      expect(dungeon).to have_received(:fit_out!)
    end

    it "knows the minions of the dungeon" do
      result = keeper.claim!(dungeon)
      expect(result).to eql(union)
    end
  end

  describe "#fit_out!" do
    it "should construct the dungeon" do
    end

    it "should provide access to the minions union" do
    end
  end

  describe "#work!" do
    let(:union) { double("Union", :delegate => true) }
    let(:dungeon) { double("Dungeon", :fit_out! => union) }

    before do
      keeper.claim!(dungeon)
    end

    it "returns true if work commenced" do
      result = keeper.work!("some_file.rb")

      expect(union).to have_received(:delegate).with(:work!, "some_file.rb")
      expect(result).to be_true
    end

    it "returns false if no minions free" do
      expect(union).to receive(:delegate).with(:work!, "some_file.rb").and_return(false)

      result = keeper.work!("some_file.rb")

      expect(result).to be_false
    end
  end

  describe "#inform_work_complete" do
    it "informs the overlord"
  end

  describe "#inform_work_result" do
    it "informs the overlord"
  end
end
