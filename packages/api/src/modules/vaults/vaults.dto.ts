import { ApiProperty } from '@nestjs/swagger';
import { Expose, Type } from 'class-transformer';
import { IsArray, IsNumber, IsOptional, IsString } from 'class-validator';
import { BigNumber } from 'ethers';

import { VaultDto } from '../../types/db.dto';
import { Tables } from '../../types/supabase';

export class VaultsDto {
  @IsArray()
  @ApiProperty({
    description: 'vaults grouped by strategy',
    type: [VaultDto],
  })
  data: Tables<'vaults'>[];

  constructor(partial: Partial<VaultsDto>) {
    Object.assign(this, partial);
  }
}

export class EntitiesDto {
  @Expose()
  type: 'treasury' | 'custodian' | 'activity_reward' | 'vault' | 'whitelist_provider';

  @Expose()
  address: string;

  @Expose()
  percentage?: number;
}

export class VaultParamsDto extends EntitiesDto {
  @ApiProperty({ type: String, example: '0xC54f8862C4bB1c114d5b6C666410eb242a6c97Db' })
  @IsString()
  owner: string;

  @ApiProperty({ type: String, example: '0xC54f8862C4bB1c114d5b6C666410eb242a6c97Db' })
  @IsString()
  operator: string;

  @ApiProperty({ type: String, example: '0xC54f8862C4bB1c114d5b6C666410eb242a6c97Db' })
  @IsString()
  asset: string;

  @ApiProperty({ type: String, example: '0xC54f8862C4bB1c114d5b6C666410eb242a6c97Db' })
  @IsString()
  token: string;

  @ApiProperty({ type: String, example: 'Test share' })
  @IsString()
  shareName: string;

  @ApiProperty({ type: String, example: 'Test symbol' })
  @IsString()
  shareSymbol: string;

  @ApiProperty({ type: BigNumber, example: '1705276800' })
  @IsNumber()
  depositOpensAt: BigNumber;

  @ApiProperty({ type: BigNumber, example: '1705286800' })
  @IsNumber()
  depositClosesAt: BigNumber;

  @ApiProperty({ type: BigNumber, example: '1705276800' })
  @IsNumber()
  redemptionOpensAt: BigNumber;

  @ApiProperty({ type: BigNumber, example: '1705286800' })
  @IsNumber()
  redemptionClosesAt: BigNumber;

  @ApiProperty({ type: String, example: '0xC54f8862C4bB1c114d5b6C666410eb242a6c97Db' })
  @IsString()
  custodian: string;

  @ApiProperty({ type: String, example: '0xC54f8862C4bB1c114d5b6C666410eb242a6c97Db' })
  @IsString()
  whiteListProvider: string;

  @ApiProperty({ type: String, example: '0xC54f8862C4bB1c114d5b6C666410eb242a6c97Db' })
  @IsString()
  treasury: string;

  @ApiProperty({ type: String, example: '0xC54f8862C4bB1c114d5b6C666410eb242a6c97Db' })
  @IsString()
  activityReward: string;

  @ApiProperty({ type: BigNumber, example: '10' })
  @IsNumber()
  promisedYield: BigNumber;

  @ApiProperty({ type: String, example: '1000000000000', description: 'Should be in wei with 6 decimals' })
  @IsString()
  maxCap: string;

  @ApiProperty({ type: String, example: '1000000000', description: 'Should be in wei with 6 decimals' })
  @IsString()
  depositThresholdForWhiteListing: string;

  @ApiProperty({
    type: EntitiesDto,
    example: [{ type: 'treasury', address: '0xC54f8862C4bB1c114d5b6C666410eb242a6c97Db', percentage: 0.8 }],
  })
  @IsArray()
  @Type(() => EntitiesDto)
  entities: EntitiesDto[];

  @ApiProperty({ type: String, nullable: true, example: '848f6e15-d1b4-423b-a080-43ef222fbd6b' })
  @IsString()
  @IsOptional()
  tenant?: string;

  constructor(partial: Partial<VaultParamsDto>) {
    super();
    Object.assign(this, partial);
  }
}

export class UpsideVaultParamsDto extends VaultParamsDto {
  @ApiProperty({ type: Number })
  @IsNumber()
  collateralPercentage: number;
}
