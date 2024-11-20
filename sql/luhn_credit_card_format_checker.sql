/*
  A function to check if a credit card number is valid or not.
*/

CREATE FUNCTION ValidateCreditCard(@CardNumber VARCHAR(19))
RETURNS BIT
AS
BEGIN
    DECLARE @ReversedCardNumber VARCHAR(19)
    DECLARE @Length INT
    DECLARE @Sum INT = 0
    DECLARE @Digit INT
    DECLARE @DoubleDigit INT
    DECLARE @i INT = 1
    
    -- Reverse the credit card number
    SET @ReversedCardNumber = REVERSE(@CardNumber)
    SET @Length = LEN(@ReversedCardNumber)
    
    -- Loop through each digit
    WHILE @i <= @Length
      BEGIN
          -- Get the current digit
          SET @Digit = CAST(SUBSTRING(@ReversedCardNumber, @i, 1) AS INT)
          
          -- If the position is even (2nd, 4th, etc.), double the digit
          IF @i % 2 = 0
            BEGIN
                SET @DoubleDigit = @Digit * 2
                
                -- If the doubled digit is greater than 9, add the two digits together
                IF @DoubleDigit > 9
                    SET @DoubleDigit = (@DoubleDigit / 10) + (@DoubleDigit % 10)
                
                SET @Sum += @DoubleDigit
            END
          ELSE
            BEGIN
                SET @Sum += @Digit
            END
            
            SET @i += 1
      END
      
      -- Check if the total sum is divisible by 10
      RETURN CASE WHEN @Sum % 10 = 0 THEN 1 ELSE 0 END
END
GO

/* Testing it */
  
DECLARE @CardNumber VARCHAR(19) = '4417123456789113';

SELECT 
    CASE 
        WHEN ValidateCreditCard(@CardNumber) = 1 THEN 'Valid' 
        ELSE 'Invalid' 
    END AS ValidationResult
