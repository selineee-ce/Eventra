import { IsEmail, IsNotEmpty, IsPhoneNumber, IsString, Matches, MinLength } from 'class-validator';

export class RegisterDto {
  @IsNotEmpty()
  @IsString()
  username!: string;

  @IsNotEmpty()
  @IsPhoneNumber()
  phone!: string;

  @IsNotEmpty()
  @IsEmail()
  email!: string;

  @IsNotEmpty()
  @IsString()
  @MinLength(8)
  @Matches(/(?=.*[A-Z])/, {
    message: 'Password must contain at least one uppercase letter.',
  })
  @Matches(/(?=.*[a-z])/, {
    message: 'Password must contain at least one lowercase letter.',
  })
  @Matches(/(?=.*\d)/, {
    message: 'Password must contain at least one number (0-9).',
  })
  @Matches(/(?=.*[!@#$%^&*()_+\-=[\]{}|;':",.\/<>?~`])/, {
    message: 'Password must contain at least one special character.',
  })
  password!: string;

  @IsNotEmpty()
  @IsString()
  @MinLength(8)
  confirmPassword!: string;

  @IsNotEmpty()
  @IsString()
  location!: string;
}