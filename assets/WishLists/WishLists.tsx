type WishListProps = { wishLists: { message: string } };

const WishLists = ({ wishLists }: WishListProps) => {
  return <div>{wishLists.message}</div>;
};

export default WishLists;
