require "money/bank/uphold"
bank = Money::Bank::Uphold.new
bank.ttl_in_seconds = 86400
Money.default_bank = bank

